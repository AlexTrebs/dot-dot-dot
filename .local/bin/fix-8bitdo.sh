#!/bin/bash
set -euo pipefail

running=$(uname -r)
if [ ! -d "/lib/modules/$running" ]; then
    echo "Modules missing for running kernel $running — reboot first."
    exit 1
fi

modprobe joydev
modprobe xpad
udevadm control --reload-rules
udevadm trigger --subsystem-match=hid

echo "Done. Unplug and replug the 8BitDo dongle."
