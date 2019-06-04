# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home', type: :system do
  describe 'Index', js: true do
    before(:each) do
      @open_grant         = create(:grant_with_users_and_questions)
      @closed_grant       = create(:published_closed_grant)
      @completed_grant    = create(:completed_grant)
      @draft_grant        = create(:draft_open_grant)
      @soft_deleted_grant = create(:grant_with_users_and_questions, deleted_at: 1.hour.ago)
    end

    scenario 'does not require a login' do
      visit root_path
      expect(page).not_to have_content 'You are not authorized to perform this action.'
    end

    scenario 'displays a published grant' do
      visit root_path
      expect(page).to have_content @open_grant.name
    end

    scenario 'does not display a closed grant' do
      visit root_path
      expect(page).not_to have_content @closed_grant.name
    end

    scenario 'does not display a completed grant' do
      visit root_path
      expect(page).not_to have_content @completed_grant.name
    end

    scenario 'does not display a draft grant' do
      visit root_path
      expect(page).not_to have_content @draft_grant.name
    end

    scenario 'does not display a soft_deleted grant' do
      visit root_path
      expect(page).not_to have_content @soft_deleted_grant.name
    end
  end
end
