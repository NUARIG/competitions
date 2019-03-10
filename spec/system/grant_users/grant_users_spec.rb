require 'rails_helper'

RSpec.describe 'GrantUsers', type: :system do
  describe 'GrantUser', js: true do
    before(:each) do
      @organization     = FactoryBot.create(:organization)
      @organization2    = FactoryBot.create(:organization)
      @admin_user       = FactoryBot.create(:user, organization: @organization,
                                                   organization_role: 'admin')
      @user             = FactoryBot.create(:user, organization: @organization,
                                                   organization_role: 'none')
      @unassigned_user  = FactoryBot.create(:user, organization: @organization)
      @grant            = FactoryBot.create(:grant, organization: @organization)
      @grant_user       = FactoryBot.create(:admin_grant_user, grant_id: @grant.id,
                                                               user_id: @user.id)
      @unaffiliated_user = FactoryBot.create(:user, organization: @organization2)

      login_as(@admin_user)
    end

    context '#edit' do
      scenario 'existing grant_user can be assigned a different role' do
        visit edit_grant_grant_user_path(@grant.id, @grant_user.id)
        expect(page).to have_content @user.name
        expect(page).to have_select('grant_user[grant_role]', text: 'admin')
        select('viewer', from:'grant_user[grant_role]')
        click_button 'Update'
        expect(page).to have_content "#{@user.name}'s permission was changed to 'viewer' for this grant."
      end
    end

    context '#new' do
      scenario 'user from another organization cannot given a role' do
        visit new_grant_grant_user_path(@grant.id)
        expect(page.all('select#grant_user_user_id option').map(&:value)).not_to include(@unaffiliated_user.id)
      end

      scenario 'assigned grant_user does not appear in select' do
        visit new_grant_grant_user_path(@grant.id)
        expect(page.all('select#grant_user_user_id option').map(&:value)).not_to include(@grant_user.id)
      end

      scenario 'unassigned user can be granted a role' do
        visit new_grant_grant_user_path(@grant.id)
        select("#{@unassigned_user.email}", from: 'grant_user[user_id]')
        select('editor', from:'grant_user[grant_role]')
        click_button 'Save'
        expect(page).to have_content "#{@unassigned_user.name} was granted 'editor'"
      end
    end

    context '#destroy' do
      scenario 'existing grant_user role can be deleted' do
        visit grant_grant_users_path(@grant.id)
        expect(page).to have_content @user.name
        click_link('Delete', href: grant_grant_user_path(@grant, @grant_user))
        page.accept_alert
        expect(page).to have_content "#{@user.name}'s role was removed for this grant"
      end
    end
  end
end
