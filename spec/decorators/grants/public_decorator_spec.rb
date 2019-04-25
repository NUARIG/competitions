# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grants::PublicDecorator do
  before do
    @open_grant = create(:open_grant_with_users_and_questions)
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

    it 'generates an apply menu link' do
      expect(@decorated_open_grant.apply_menu_link).to have_css("li#apply-grant_#{@open_grant.id}")
      expect(@decorated_open_grant.apply_menu_link).to have_css("a#apply-grant_#{@open_grant.id}-link", text: 'Apply Now')
    end

  end

  context 'user with no roles' do
    before(:each) do
      @admin_user = @open_grant.grant_users.grant_role_admin.first.user
      sign_in @admin_user
      @decorated_open_grant = Grants::PublicDecorator.decorate(@open_grant)
    end

    it 'generates an edit link' do
      expect(@decorated_open_grant.edit_menu_link).to have_css("li#edit-grant_#{@open_grant.id}")
      expect(@decorated_open_grant.edit_menu_link).to have_css("a#edit-grant_#{@open_grant.id}-link", text: 'Edit')
    end

    it 'generates an apply menu link' do
      expect(@decorated_open_grant.apply_menu_link).to have_css("li#apply-grant_#{@open_grant.id}")
      expect(@decorated_open_grant.apply_menu_link).to have_css("a#apply-grant_#{@open_grant.id}-link", text: 'Apply Now')
    end
  end

  # TODO: Allow for unauthorized user in test
  #       https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs
  pending 'unauthenticated user' do
    before(:each) do
      sign_in nil
      @decorated_open_grant = Grants::PublicDecorator.decorate(@open_grant)
    end
  end
end
