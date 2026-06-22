import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    text: String,
    successText: String,
    errorText: String
  }

  connect() {
    if (this.hasButtonTarget) {
      this.defaultText = this.buttonTarget.textContent.trim()
    }
  }

  async copy(event) {
    event.preventDefault()

    const text = this.textValue || globalThis.location.href

    try {
      if (globalThis.navigator?.clipboard?.writeText) {
        await globalThis.navigator.clipboard.writeText(text)
      } else {
        this.copyWithFallback(text)
      }

      this.flashButtonText(this.successTextValue || "Copied")
    } catch (_error) {
      this.flashButtonText(this.errorTextValue || "Could not copy")
    }
  }

  copyWithFallback(text) {
    const input = document.createElement("textarea")
    input.value = text
    input.setAttribute("readonly", "")
    input.style.position = "absolute"
    input.style.left = "-9999px"
    document.body.appendChild(input)

    input.select()
    document.execCommand("copy")
    document.body.removeChild(input)
  }

  flashButtonText(text) {
    if (!this.hasButtonTarget) return

    this.buttonTarget.textContent = text
    clearTimeout(this.resetTimeout)

    this.resetTimeout = setTimeout(() => {
      this.buttonTarget.textContent = this.defaultText
    }, 1400)
  }

  disconnect() {
    clearTimeout(this.resetTimeout)
  }
}
