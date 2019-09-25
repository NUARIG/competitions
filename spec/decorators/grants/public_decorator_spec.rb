# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grants::PublicDecorator do
  before do
    @open_grant = create(:open_grant_with_users)
  end

  context 'user with no roles' do
    before(:each) do
      @user = create(:user)
      sign_in @user
      @decorated_open_grant = Grants::PublicDecorator.decorate(@open_grant)
    end

    it 'does not generate an edit link' do
      expect(@decorated_open_grant.edit_menu_link).not_to have_css("li#edit-grant_#{@open_grant.id}")
      expect(@decorated_open_grant.edit_menu_link).not_to have_css("a#edit-grant_#{@open_grant.id}-link", text: 'Edit')
    end
  end

  context 'admin user' do
    before(:each) do
      @admin_user = @open_grant.grant_permissions.role_admin.first.user
      sign_in @admin_user
      @decorated_open_grant = Grants::PublicDecorator.decorate(@open_grant)
    end

    it 'generates an edit link' do
      expect(@decorated_open_grant.edit_menu_link).to have_css("li#edit-grant_#{@open_grant.id}")
      expect(@decorated_open_grant.edit_menu_link).to have_css("a#edit-grant_#{@open_grant.id}-link", text: 'Edit')
    end
  end

  context 'unauthenticated user' do
    before(:each) do
      @decorated_open_grant = Grants::PublicDecorator.decorate(@open_grant)
    end

    it 'does not generate an edit link' do
      allow(h).to receive(:user_signed_in?).and_return(false)
      expect(@decorated_open_grant.edit_menu_link).not_to have_css("li#edit-grant_#{@open_grant.id}")
      expect(@decorated_open_grant.edit_menu_link).not_to have_css("a#edit-grant_#{@open_grant.id}-link", text: 'Edit')
    end
  end
end
