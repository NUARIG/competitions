require 'rails_helper'

RSpec.describe 'Grants', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      @organization = FactoryBot.create(:organization)
      @user         = FactoryBot.create(:user, organization: @organization, organization_role: 'editor')
      @grant        = FactoryBot.create(:grant, organization: @organization)

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

    scenario 'versioning tracks whodunnit', versioning: true do
      expect(PaperTrail).to be_enabled
      fill_in 'grant_name', with: 'New_Name'
      click_button 'Save and Complete'

      expect(page).to have_content 'Grant was successfully updated.'
      expect(@grant.versions.last.whodunnit).to eql(@user.id)
    end
  end
end
