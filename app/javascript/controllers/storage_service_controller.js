import { Controller } from "@hotwired/stimulus"

// Enables the Azure fields only while the Azure radio button is selected.
export default class extends Controller {
  static targets = ["azureFields"]

  toggle(event) {
    this.azureFieldsTarget.disabled = event.target.value !== "azure"
  }
}
