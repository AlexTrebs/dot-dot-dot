import app from "ags/gtk4/app"
import style from "./style.css"
import Desktop from "./widget/Desktop"

app.start({
  css: style,
  main() {
    app.get_monitors().map(Desktop)
  },
})
