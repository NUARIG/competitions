import TomSelect      from "tom-select"
import { Controller } from "@hotwired/stimulus"
import { get }        from "@rails/request.js"

// Connects to data-controller="ts--search"
export default class extends Controller {
  static values = { url: String, maxOptions: String, placeholder: String }

  connect() {
    var config = {
      plugins: ['dropdown_input'],
      maxItems: 1,
      maxOptions: (parseInt(this.maxOptionsValue) || null),
      selectOnTab: true,
      closeAfterSelect: true,
      hidePlaceholder: false,
      placeholder: (this.placeholderValue || ''),
      create: false,
      openOnFocus: true,
      highlight: true
    }

    if (this.urlValue !== '') {
      config.load = ((q, callback) => this.search(q, callback))
    }

    new TomSelect(this.element, config)
    this.element.querySelector("select").style.display = "none"
  }

  async search(q, callback) {
    if (this.urlValue === undefined) {
      callback()
    }

    const response = await get(this.urlValue, {
      query: { q: q },
      responseKind: 'json'
    })

    if (response.ok) {
      const list = await response.json
      callback(list)
    } else {
      callback()
    }
  }
}
