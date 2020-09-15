# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Criteria', type: :system, js: true do
  describe 'Index' do
    let(:grant) { create(:draft_grant) }
    let(:admin) { grant.administrators.first }

    before(:each) do
      login_as(admin, scope: :saml_user)
      visit criteria_grant_path(grant)
    end

    context '#index' do
      scenario "it displays the grant's criteria" do
        grant.criteria.each do |criterion|
          expect(page).to have_field('Criterion Name', with: criterion.name)
        end
      end
    end

    context '#update' do
      scenario 'it deletes a criterion' do
        expect do
          find('.remove', match: :first).click
          click_button 'Save'
        end.to change{grant.criteria.count}.by(-1)
        expect(page).to have_content 'Criteria updated'
      end

      scenario 'adds a criterion form to the page' do
        expect(page).not_to have_field('Criterion Name', with: '')
        click_link 'Add a New Review Criterion'
        expect(page).to have_field('Criterion Name', with: '')
      end

      it 'adds and displays a new criterion' do
        new_criteria_name = Faker::Lorem.sentence
        click_link 'Add a New Review Criterion'
        find_field('Criterion Name', with: '').set(new_criteria_name)
        click_button 'Save'
        expect(page).to have_field('Criterion Name', with: new_criteria_name)
      end

      scenario 'disallows an empty criterion form' do
        expect do
          click_link 'Add a New Review Criterion'
          click_button 'Save'
        end.not_to change{grant.criteria.count}
      end

      scenario 'disallows a duplicate criteria name' do
        expect do
          click_link 'Add a New Review Criterion'
          find_field('Criterion Name', with: '').set(grant.criteria.first.name)
          click_button 'Save'
        end.not_to change{grant.criteria.count}
        expect(page).to have_content 'Criteria name has already been taken'
      end

      scenario 'requires one criteria' do
        page.all(:link, 'Remove').each do |remove_button|
          remove_button.click
        end
        expect do
          click_button 'Save'
        end.not_to change{grant.criteria.count}
        sleep(0.5)
        expect(page).to have_content 'Must have at least one review criteria.'
      end

      context 'paper_trail', versioning: true do
        scenario 'it tracks whodunnit' do
          find_field('Criterion Name', with: grant.criteria.last.name).set(Faker::Lorem.sentence)
          click_button 'Save'
          expect(grant.criteria.last.versions.last.whodunnit).to be admin.id
        end
      end
    end
  end
end
