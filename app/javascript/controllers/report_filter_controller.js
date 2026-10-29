import { Controller } from "@hotwired/stimulus"

// File-level filtering only: the source report stays complete in the DOM.
// Native <details> owns disclosure state; no duplicate custom accordion.
export default class extends Controller {
  static targets = ["query", "file", "nav", "count", "empty"]
  static values = { countTemplate: String }

  connect() {
    this.filter()
  }

  filter() {
    if (!this.hasQueryTarget) return

    const query = this.queryTarget.value.trim().toLocaleLowerCase()
    let visible = 0

    this.fileTargets.forEach((file, index) => {
      const match = file.textContent.toLocaleLowerCase().includes(query)
      file.hidden = !match
      if (this.navTargets[index]) this.navTargets[index].hidden = !match
      if (match) visible += 1
    })

    if (this.hasCountTarget) {
      this.countTarget.textContent = this.countTemplateValue
        .replace("__SHOWN__", visible)
        .replace("__TOTAL__", this.fileTargets.length)
    }
    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible !== 0
  }

  openFile(event) {
    const id = event.currentTarget.getAttribute("href")?.slice(1)
    const file = this.fileTargets.find((target) => target.id === id)
    if (file) file.open = true
  }

  expandAll() {
    this.fileTargets.filter((file) => !file.hidden).forEach((file) => { file.open = true })
  }

  collapseAll() {
    this.fileTargets.forEach((file) => { file.open = false })
  }
}
