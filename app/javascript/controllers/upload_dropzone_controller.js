import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropzone", "filename", "input", "progress", "progressBar", "status", "submit"]
  static values = {
    completeText: String,
    errorText: String,
    readyText: String,
    selectedText: String,
    uploadingText: String
  }

  connect() {
    this.reset()
  }

  browse(event) {
    event.preventDefault()
    this.inputTarget.click()
  }

  dragover(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.add("is-dragover")
  }

  dragleave(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove("is-dragover")
  }

  drop(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove("is-dragover")

    if (event.dataTransfer.files.length === 0) return

    this.inputTarget.files = event.dataTransfer.files
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  selected() {
    const file = this.inputTarget.files[0]

    if (!file) {
      this.reset()
      return
    }

    this.filenameTarget.textContent = file.name
    this.statusTarget.textContent = this.selectedTextValue
    this.submitTarget.disabled = false
    this.element.requestSubmit()
  }

  initializeUpload() {
    this.showProgress()
    this.setProgress(0)
  }

  start() {
    this.inputTarget.disabled = true
    this.submitTarget.disabled = true
    this.statusTarget.textContent = this.uploadingTextValue
    this.showProgress()
  }

  progress(event) {
    this.setProgress(event.detail.progress)
  }

  error(event) {
    event.preventDefault()
    this.inputTarget.disabled = false
    this.submitTarget.disabled = false
    this.statusTarget.textContent = event.detail.error || this.errorTextValue
    this.dropzoneTarget.classList.add("is-invalid")
  }

  end() {
    this.setProgress(100)
    this.statusTarget.textContent = this.completeTextValue
  }

  reset() {
    this.statusTarget.textContent = this.readyTextValue
    this.filenameTarget.textContent = ""
    this.submitTarget.disabled = true
    this.dropzoneTarget.classList.remove("is-dragover", "is-invalid")
    this.progressTarget.classList.add("d-none")
    this.setProgress(0)
  }

  showProgress() {
    this.progressTarget.classList.remove("d-none")
  }

  setProgress(value) {
    const progress = Math.round(value)
    const progressElement = this.progressTarget.querySelector("[role='progressbar']")

    this.progressBarTarget.style.width = `${progress}%`
    progressElement.setAttribute("aria-valuenow", progress)
    this.progressBarTarget.textContent = progress > 10 ? `${progress}%` : ""
  }
}
