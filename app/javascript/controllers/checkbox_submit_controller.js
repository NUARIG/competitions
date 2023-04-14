import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox-submit"
export default class extends Controller {
  submit(e) {
    e.srcElement.form.requestSubmit();
  }
}
