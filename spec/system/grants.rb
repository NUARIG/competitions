require 'rails_helper'
require 'rake'

RSpec.describe 'Grants', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      @organization = FactoryBot.create(:organization)
      @user         = FactoryBot.create(:user, organization_id: @organization.id )
      @grant        = FactoryBot.create(:grant, organization_id: @organization.id)

      login_as(@user)
      visit edit_grant_path(@grant.id)
    end

    scenario 'date fields edited with datepicker are properly formatted' do
      tomorrow = (Date.current + 1.day).to_s

      expect(page).to have_field('grant_initiation_date', with: @grant.initiation_date)
      page.execute_script("$('#grant_initiation_date').fdatepicker('setDate',new Date('#{tomorrow}'))")
      click_button 'Save and Complete'
      expect(@grant.reload.initiation_date.to_s).to eql(tomorrow)
    end
  end
end
