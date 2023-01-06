import { Controller } from "@hotwired/stimulus"

// Dynamic search
export default class extends Controller {
  submit(event) {
    this.element.requestSubmit()
  }
}
