import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
	static targets = ['score', 'comment']

	clear_score(event) {
		event.preventDefault();

		let scored_button = this.scoreTarget.querySelector('input:checked');
		
		if (scored_button) {
			scored_button.checked = false
		}
	}

	commentTargetConnected(target) {
		if (target.valueOf) {
			this.#set_textarea_height(target);
		}
	}

	expand_comment_area(event) {
		let commentArea = event.target;

		if (commentArea.style.height.slice(-1,2) < commentArea.scrollHeight) {
			this.#set_textarea_height(commentArea);
		}
	}

	// private
	#set_textarea_height(textArea) {
		textArea.style.height = textArea.scrollHeight + `px`;
	}
}
