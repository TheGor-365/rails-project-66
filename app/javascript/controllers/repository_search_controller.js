import { Controller } from "@hotwired/stimulus"

// Client-side filtering keeps GitHub repository IDs and the existing form submission intact.
export default class extends Controller {
  static targets = ["query", "select", "count"]
  static values = { countTemplate: String }

  connect() {
    this.allOptions = Array.from(this.selectTarget.options, (option) => option.cloneNode(true))
    this.totalCount = this.allOptions.filter((option) => option.value !== "").length
    this.updateCount(this.totalCount)
  }

  filter() {
    const query = this.queryTarget.value.trim().toLocaleLowerCase()
    const selectedId = this.selectTarget.value

    const matching = this.allOptions.filter(
      (option) => option.value === "" || option.text.toLocaleLowerCase().includes(query)
    )

    this.selectTarget.replaceChildren(...matching.map((option) => option.cloneNode(true)))
    this.selectTarget.value = matching.some((option) => option.value === selectedId) ? selectedId : ""
    this.updateCount(matching.filter((option) => option.value !== "").length)
  }

  updateCount(shown) {
    this.countTarget.textContent = this.countTemplateValue
      .replace("__SHOWN__", shown)
      .replace("__TOTAL__", this.totalCount)
  }
}
