import TomSelect      from "tom-select"
import { Controller } from "@hotwired/stimulus"
import { get }        from "@rails/request.js"

// Connects to data-controller="ts--search"
export default class extends Controller {
  static values = { url: String }

  connect() {

    var config = {
      plugins: ['dropdown_input'],
      maxItems: 1,
      maxOptions: 3,
      selectOnTab: true,
      closeAfterSelect: true,
      hidePlaceholder: false,
      placeholder: 'Enter 3 characters to search',
      create: false,
      openOnFocus: true,
      highlight: true,
      load: (q, callback) => this.search(q, callback)
    }

    new TomSelect(this.element, config)
  }

  async search(q, callback) {
    const response = await get(this.urlValue, {
      query: { q: q },
      responseKind: 'json'
    })

    if (response.ok) {
      const list = await response.json
      callback(list)
    } else {
      console.log(response)
      callback()
    }
  }
}
