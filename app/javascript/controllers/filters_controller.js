import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['search', 'filterable']

  filter() {
    let searchTerm = this.searchTarget.value.toLowerCase()

    this.filterableTargets.forEach((el, i) => {
      let grantTitle = (el.querySelector('.name > a').innerText.toLowerCase())

      if (!grantTitle.includes(searchTerm)) {
        el.closest('.cell').classList.add('filtered')
      } else {
        el.closest('.cell').classList.remove('filtered')
      }
    })
  }
}
