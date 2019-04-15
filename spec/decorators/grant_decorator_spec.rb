# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantDecorator do
  context 'Published open grant' do
    before do
      @open_grant = create(:open_grant_with_users_and_questions)
    end

    describe '#name_length_class' do
      it 'returns "long" for a name over 50 characters' do
        @open_grant.name      = Faker::Lorem.characters(rand(51..255))
        @decorated_open_grant = GrantDecorator.decorate(@open_grant)
        expect(@decorated_open_grant.name_length_class).to eql('long')
      end

      it 'returns "medium" for a name over 35 and under 50 characters' do
        @open_grant.name      = Faker::Lorem.characters(rand(35..50))
        @decorated_open_grant = GrantDecorator.decorate(@open_grant)
        expect(@decorated_open_grant.name_length_class).to eql('medium')
      end

      it 'returns nil for a name over 35 and under 50 characters' do
        @open_grant.name      = Faker::Lorem.characters(rand(10..34))
        @decorated_open_grant = GrantDecorator.decorate(@open_grant)
        expect(@decorated_open_grant.name_length_class).to be_nil
      end
    end

    describe '#menu_links' do
      context 'user with no roles' do
        before(:each) do
          @user = create(:user)
          sign_in @user
          @decorated_open_grant = GrantDecorator.decorate(@open_grant)
        end

        it 'generates a show menu link' do
          expect(@decorated_open_grant.show_menu_link).to have_css("li#show-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.show_menu_link).to have_css("a#show-grant_#{@open_grant.id}-link", text: 'RFA')
        end

        it 'generates an apply menu link' do
          expect(@decorated_open_grant.apply_menu_link).to have_css("li#apply-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.apply_menu_link).to have_css("a#apply-grant_#{@open_grant.id}-link", text: 'Apply Now')
        end

        it 'does not generate an edit menu link' do
          expect(@decorated_open_grant.edit_menu_link).not_to have_css("li#edit-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.edit_menu_link).not_to have_css("a#edit-grant_#{@open_grant.id}-link", text: 'Edit')
        end

        it 'does not generate a submission menu link' do
          expect(@decorated_open_grant.view_submissions_menu_link).not_to have_css("li#submissions-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.view_submissions_menu_link).not_to have_css("a#submissions-grant_#{@open_grant.id}-link", text: 'View Submissions')
        end
      end

      context 'grant admin user' do
        before(:each) do
          @admin_user = @open_grant.grant_users.grant_role_admin.first.user
          sign_in @admin_user
          @decorated_open_grant = GrantDecorator.decorate(@open_grant)
        end

        it 'generates a show menu link' do
          expect(@decorated_open_grant.show_menu_link).to have_css("li#show-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.show_menu_link).to have_css("a#show-grant_#{@open_grant.id}-link", text: 'RFA')
        end

        it 'generates an apply menu link' do
          expect(@decorated_open_grant.apply_menu_link).to have_css("li#apply-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.apply_menu_link).to have_css("a#apply-grant_#{@open_grant.id}-link", text: 'Apply Now')
        end

        it 'generates an edit menu link' do
          expect(@decorated_open_grant.edit_menu_link).to have_css("li#edit-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.edit_menu_link).to have_css("a#edit-grant_#{@open_grant.id}-link", text: 'Edit')
        end

        it 'generates a submission menu link' do
          expect(@decorated_open_grant.view_submissions_menu_link).to have_css("li#submissions-grant_#{@open_grant.id}")
          expect(@decorated_open_grant.view_submissions_menu_link).to have_css("a#submissions-grant_#{@open_grant.id}-link", text: 'View Submissions')
        end
      end
    end
  end

  context 'Published closed grant' do
    before do
      @closed_grant = GrantDecorator.decorate(build_stubbed(:published_closed_grant))
    end

    it 'does not generate an apply menu link' do
      expect(@closed_grant.apply_menu_link).to be_nil
    end
  end

  context 'Published not yet open grant' do
    before do
      @not_yet_open_grant = GrantDecorator.decorate(build_stubbed(:published_not_yet_open_grant))
    end

    it 'does not generate an apply menu link' do
      expect(@not_yet_open_grant.apply_menu_link).to be_nil
    end
  end
end
