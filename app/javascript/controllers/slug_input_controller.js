import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  filter(e) {
    const input = e.target;
    const newValue = input.value.replace(/[^a-zA-Z0-9-_]/g, "");
    input.value = newValue;
  }
}
