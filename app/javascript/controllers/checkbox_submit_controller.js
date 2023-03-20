import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox-submit"
export default class extends Controller {
  toggle(e) {
    console.log(e.srcElement.form.submit());
  }
}
