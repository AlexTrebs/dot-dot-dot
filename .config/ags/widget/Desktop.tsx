import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync, subprocess, exec } from "ags/process"
import { createExternal, createMemo, For } from "ags"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

const HOME = GLib.get_home_dir()

// --- Config ---
type ExtensionHandler =
  | { handler: "desktop" }
  | { command: string | string[], icon: string | "mimetype" }

const config = {
  desktopDir: `${HOME}/Desktop`,
  hotReload: true,
  iconSize: 40,
  panelWidth: 300,
  extensions: {
    ".desktop": { handler: "desktop" },
    ".sh":      { command: ["alacritty", "-e", "bash"], icon: "text-x-script" },
    ".png":     { command: "xdg-open", icon: "mimetype" },
    ".jpg":     { command: "xdg-open", icon: "mimetype" },
    ".jpeg":    { command: "xdg-open", icon: "mimetype" },
    ".pdf":     { command: "xdg-open", icon: "mimetype" },
    ".mp4":     { command: "xdg-open", icon: "mimetype" },
    ".mkv":     { command: "xdg-open", icon: "mimetype" },
    ".webm":    { command: "xdg-open", icon: "mimetype" },
  } as Record<string, ExtensionHandler>,
}

// --- Types ---
type Shortcut = {
  label: string
  gicon: Gio.Icon
  command: () => void
}

// --- File helpers ---
function getMimeIcon(filePath: string): Gio.Icon {
  try {
    const file = Gio.File.new_for_path(filePath)
    const info = file.query_info("standard::icon", Gio.FileQueryInfoFlags.NONE, null)
    return info.get_icon() ?? Gio.ThemedIcon.new("application-x-generic")
  } catch {
    return Gio.ThemedIcon.new("application-x-generic")
  }
}

function parseFiles(): Shortcut[] {
  const shortcuts: Shortcut[] = []
  try {
    const dir = Gio.File.new_for_path(config.desktopDir)
    const enumerator = dir.enumerate_children("standard::name,standard::type", Gio.FileQueryInfoFlags.NONE, null)
    let info: Gio.FileInfo | null
    while ((info = enumerator.next_file(null)) !== null) {
      const name = info.get_name()
      const ext = name.includes(".") ? `.${name.split(".").pop()!.toLowerCase()}` : ""
      const handler = config.extensions[ext]
      if (!handler) continue
      const filePath = `${config.desktopDir}/${name}`
      try {
        if ("handler" in handler) {
          const keyfile = new GLib.KeyFile()
          keyfile.load_from_file(filePath, GLib.KeyFileFlags.NONE)
          const label = keyfile.get_string("Desktop Entry", "Name")
          const iconName = keyfile.get_string("Desktop Entry", "Icon")
          const rawExec = keyfile.get_string("Desktop Entry", "Exec")
          const execCmd = rawExec.replace(/%[uUfFickdDnNvm%]/g, "").trim().split(/\s+/)
          shortcuts.push({ label, gicon: Gio.ThemedIcon.new(iconName), command: () => execAsync(execCmd) })
        } else {
          const { command, icon } = handler
          const gicon = icon === "mimetype" ? getMimeIcon(filePath) : Gio.ThemedIcon.new(icon)
          const label = name.replace(/\.[^.]+$/, "")
          const cmd = Array.isArray(command) ? [...command, filePath] : [command, filePath]
          shortcuts.push({ label, gicon, command: () => execAsync(cmd) })
        }
      } catch { /* skip */ }
    }
  } catch { /* dir missing */ }
  return shortcuts
}

// --- Metrics ---
function poll<T>(initial: T, read: () => T, intervalMs: number) {
  return createExternal(initial, (set) => {
    const id = GLib.timeout_add(GLib.PRIORITY_DEFAULT, intervalMs, () => { set(read()); return GLib.SOURCE_CONTINUE })
    return () => GLib.source_remove(id)
  })
}

function readCpuStat() {
  const vals = exec(["cat", "/proc/stat"]).split("\n")[0].split(/\s+/).slice(1).map(Number)
  return { idle: vals[3] + (vals[4] || 0), total: vals.reduce((a, b) => a + b, 0) }
}
let prevCpu = readCpuStat()
function getCpu(): number {
  const curr = readCpuStat(), dt = curr.total - prevCpu.total, di = curr.idle - prevCpu.idle
  prevCpu = curr
  return dt > 0 ? Math.round((1 - di / dt) * 100) : 0
}

function getRam(): { used: number, total: number } {
  const out = exec(["cat", "/proc/meminfo"])
  const get = (k: string) => { const m = out.match(new RegExp(`^${k}:\\s+(\\d+)`, "m")); return m ? parseInt(m[1]) : 0 }
  const total = get("MemTotal"), avail = get("MemAvailable")
  return { used: (total - avail) / 1048576, total: total / 1048576 }
}

let diskCache: { used: number, total: number } = { used: 0, total: 0 }
execAsync(["df", "-B1", "/"]).then(out => {
  const parts = out.split("\n")[1].trim().split(/\s+/)
  diskCache = { used: parseInt(parts[2]) / 1e9, total: parseInt(parts[1]) / 1e9 }
}).catch(() => {})
function getDisk(): { used: number, total: number } {
  execAsync(["df", "-B1", "/"]).then(out => {
    const parts = out.split("\n")[1].trim().split(/\s+/)
    diskCache = { used: parseInt(parts[2]) / 1e9, total: parseInt(parts[1]) / 1e9 }
  }).catch(() => {})
  return diskCache
}

function readNetRaw() {
  let rx = 0, tx = 0
  for (const line of exec(["cat", "/proc/net/dev"]).split("\n").slice(2)) {
    const p = line.trim().split(/\s+/)
    if (!p[0] || p[0] === "lo:") continue
    rx += parseInt(p[1]) || 0; tx += parseInt(p[9]) || 0
  }
  return { rx, tx }
}
let prevNet = { ...readNetRaw(), time: Date.now() }
function getNet(): { rx: number, tx: number } {
  const curr = readNetRaw(), now = Date.now(), dt = (now - prevNet.time) / 1000
  const rx = dt > 0 ? Math.max(0, (curr.rx - prevNet.rx) / 1024 / dt) : 0
  const tx = dt > 0 ? Math.max(0, (curr.tx - prevNet.tx) / 1024 / dt) : 0
  prevNet = { ...curr, time: now }
  return { rx, tx }
}
function fmtSpeed(kb: number): string {
  return kb < 1000 ? `${Math.round(kb)} KB/s` : `${(kb / 1024).toFixed(1)} MB/s`
}

const cpuMetric  = poll(0,                getCpu,  2000)
const ramMetric  = poll(getRam(),         getRam,  5000)
const diskMetric = poll(getDisk(),        getDisk, 30000)
const netMetric  = poll({ rx: 0, tx: 0 }, getNet,  2000)

const cpuVal  = createMemo(() => `${cpuMetric()}%`)
const ramVal  = createMemo(() => { const r = ramMetric();  return `${r.used.toFixed(1)} / ${r.total.toFixed(0)} GB` })
const diskVal = createMemo(() => { const d = diskMetric(); return `${d.used.toFixed(0)} / ${d.total.toFixed(0)} GB` })
const netVal  = createMemo(() => { const n = netMetric();  return `↑ ${fmtSpeed(n.tx)}   ↓ ${fmtSpeed(n.rx)}` })

const cpuFrac  = createMemo(() => cpuMetric() / 100)
const ramFrac  = createMemo(() => { const r = ramMetric();  return r.total > 0 ? r.used / r.total : 0 })
const diskFrac = createMemo(() => { const d = diskMetric(); return d.total > 0 ? d.used / d.total : 0 })

// --- Hyprland window state ---
function checkWindows(): boolean {
  try {
    const clients = JSON.parse(exec(["hyprctl", "clients", "-j"]))
    const activeWs = JSON.parse(exec(["hyprctl", "activeworkspace", "-j"]))
    return clients.some((c: { workspace: { id: number } }) => c.workspace.id === activeWs.id)
  } catch { return false }
}

const windowsOpen = createExternal(checkWindows(), (set) => {
  set(checkWindows())
  const xdgRuntime = GLib.getenv("XDG_RUNTIME_DIR")
  const hyprSig = GLib.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  if (!xdgRuntime || !hyprSig) return
  const proc = subprocess(
    ["socat", "-u", `UNIX-CONNECT:${xdgRuntime}/hypr/${hyprSig}/.socket2.sock`, "-"],
    (line) => {
      if (/openwindow|fullscreen|workspace|movewindow/.test(line)) set(checkWindows())
      if (/closewindow/.test(line)) GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => { set(checkWindows()); return GLib.SOURCE_REMOVE })
    },
  )
  return () => proc.kill()
})

const shortcuts = createExternal(parseFiles(), (set) => {
  set(parseFiles())
  if (!config.hotReload) return
  const monitor = Gio.File.new_for_path(config.desktopDir).monitor_directory(Gio.FileMonitorFlags.NONE, null)
  monitor.connect("changed", () => set(parseFiles()))
  return () => monitor.cancel()
})

const shortcutRows = createMemo(() => {
  const list = shortcuts()
  const rows: Shortcut[][] = []
  for (let i = 0; i < list.length; i += 2) rows.push(list.slice(i, i + 2))
  return rows
})

const showDesktop = createMemo(() => !windowsOpen())

// --- Widget ---
export default function Desktop(gdkmonitor: Gdk.Monitor) {
  return <window
    visible={showDesktop}
    application={app}
    gdkmonitor={gdkmonitor}
    name="desktop"
    class="Desktop"
    layer={Astal.Layer.BACKGROUND}
    anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT}
    exclusivity={Astal.Exclusivity.NORMAL}
    widthRequest={config.panelWidth}
  >
    <box cssClasses={["panel"]} orientation={Gtk.Orientation.VERTICAL}>

      {/* Stats */}
      <box cssClasses={["metrics"]} orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        {([
          ["󰻠  CPU",  cpuVal,  "metric-val-cpu",  cpuFrac,  "bar-cpu"],
          ["󰍛  RAM",  ramVal,  "metric-val-ram",  ramFrac,  "bar-ram"],
          ["󰋊  Disk", diskVal, "metric-val-disk", diskFrac, "bar-disk"],
        ] as [string, ReturnType<typeof createMemo>, string, ReturnType<typeof createMemo>, string][]).map(([key, val, valCls, frac, barCls]) => (
          <box cssClasses={["metric-row"]} orientation={Gtk.Orientation.VERTICAL} spacing={4}>
            <box orientation={Gtk.Orientation.HORIZONTAL}>
              <label cssClasses={["metric-key"]} label={key} halign={Gtk.Align.START} hexpand={true} />
              <label cssClasses={["metric-val", valCls]} label={val} halign={Gtk.Align.END} />
            </box>
            <levelbar cssClasses={["stat-bar", barCls]} value={frac} minValue={0} maxValue={1} />
          </box>
        ))}
        <box cssClasses={["metric-row"]} orientation={Gtk.Orientation.VERTICAL} spacing={2}>
          <label cssClasses={["metric-key"]} label="󰈀  Net" halign={Gtk.Align.START} />
          <label cssClasses={["metric-val", "metric-val-net"]} label={netVal} halign={Gtk.Align.START} />
        </box>
      </box>

      {/* Icons grid */}
      <scrolledwindow
        vexpand={true}
        hscrollbarPolicy={Gtk.PolicyType.NEVER}
        vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
      >
        <box cssClasses={["grid"]} orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          <For each={shortcutRows}>
            {(row) => (
              <box orientation={Gtk.Orientation.HORIZONTAL} spacing={8} homogeneous={true}>
                {row.map(s => (
                  <button cssClasses={["card"]} onClicked={s.command} hexpand={true}>
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={6} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
                      <image gicon={s.gicon} pixelSize={config.iconSize} halign={Gtk.Align.CENTER} />
                      <label cssClasses={["card-label"]} label={s.label} halign={Gtk.Align.CENTER} ellipsize={3} maxWidthChars={9} />
                    </box>
                  </button>
                ))}
              </box>
            )}
          </For>
        </box>
      </scrolledwindow>

    </box>
  </window>
}
