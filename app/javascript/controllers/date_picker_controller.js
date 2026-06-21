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
  }

  disconnect() {
    this.picker?.destroy()
  }
}
