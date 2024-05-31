import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // selectively re-load Foundation js on turbo actions
    //  e.g. fixes opened drop-down menus turbo streams
    const connectedElement = this.element;
    $(connectedElement).foundation();
  }
}
