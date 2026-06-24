import { Controller } from "@hotwired/stimulus"
import "flatpickr"

export default class extends Controller {
  static values = {
    dateFormat: { type: String, default: "d/m/Y" }
  }

  connect() {
    this.picker = globalThis.flatpickr(this.element, {
      allowInput: true,
      dateFormat: this.dateFormatValue,
      disableMobile: true
    })

    this.applyTheme()
    this.themeObserver = new MutationObserver(() => this.applyTheme())
    this.themeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-bs-theme"]
    })
  }

  disconnect() {
    this.themeObserver?.disconnect()
    this.picker?.destroy()
  }

  applyTheme() {
    const darkThemeEnabled = document.documentElement.dataset.bsTheme === "dark"
    const darkThemeStylesheet = document.getElementById("flatpickr-dark-theme")

    if (darkThemeStylesheet) {
      darkThemeStylesheet.disabled = !darkThemeEnabled
    }
  }
}
