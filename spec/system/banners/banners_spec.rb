# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Banners', type: :system do
  describe 'Index', js: true do
    before(:each) do
      @banner             = create(:banner)
      visit root_path
    end



    describe 'user should not have access' do
      before(:each) do
        @user  = create(:user)
        login_as @user
      end

      context '#index' do
        scenario 'displays proper error message for non-admin user' do
          visit banners_path
          expect(current_path).to eq("/")
          expect(page).to have_content('You are not authorized to perform this action.')
        end
      end
    end

    describe 'admin user' do
      before(:each) do
        @system_admin_user  = create(:system_admin_user)
        login_as @system_admin_user

        visit root_path
      end

      context 'home page' do
        context 'header links' do
          scenario 'displays login link' do
            expect(page).to have_link 'Admin'
          end

          scenario 'displays the Banners link for admins' do
            click_link 'Admin'
            click_link 'Banners'
            expect(current_path).to eq("/banners")
          end
        end
      end

      context 'test restful controller actions' do
        before(:each) do
          visit banners_path
        end

        context '#index' do
          scenario 'banner index page' do
            expect(page).to have_content 'Banners'
          end

        end

        context '#create' do
          scenario 'Shows error for empty body' do
            click_link 'Create New Banner'
            expect(current_path).to eq("/banners/new")
            click_button 'Save'
            expect(page).to have_content('Body is required.')
          end

          scenario 'create a banner' do
            @body = Faker::Lorem.sentence
            @body_list_name = @body.split.first

            click_link 'Create New Banner'
            expect(current_path).to eq("/banners/new")
            fill_in_trix_editor('banner_body', with: @body)
            click_button 'Save'
            expect(current_path).to eq("/banners")
            expect(page).to have_content('Banner was created and will continue to be visible until that setting is changed or it is deleted.')
            expect(page).to have_content(@body_list_name)

            visit root_path
            expect(page).to have_content(@body)
          end
        end

        context '#delete' do
          scenario ' delete a banner success' do
            expect(page).to have_content(@banner.body.split.first)
            click_link 'Delete'
            page.driver.browser.switch_to.alert.accept
            expect(page).not_to have_content(@banner.body.split.first)
          end
        end

        context '#edit' do
          before(:each) do
            @body = Faker::Lorem.sentence
            @body_list_name = @body.split.first
          end

          scenario 'edit a banner' do
            expect(page).to have_content(@banner.body.split.first)
            click_link 'Edit'
            expect(current_path).to eq("/banners/#{@banner.id}/edit")
            fill_in_trix_editor('banner_body', with: @body)
            click_button 'Update'
            expect(current_path).to eq("/banners")
            expect(page).to have_content(@body_list_name)


          end

          scenario 'unsuccessful edit of a banner' do
            # TODO: This doesn't want to reset the body text to nil or ''.

            # @empty = ''
            # expect(page).to have_content(@banner.body.split.first)
            # click_link 'Edit'
            # expect(current_path).to eq("/banners/#{@banner.id}/edit")
            # fill_in_trix_editor('banner_body', with: @empty)
            # click_button 'Update'
            # expect(page).to have_content('Please review the following error')
          end

        end
      end
    end

    describe 'banner display on home page' do

      before(:each) do
        visit root_path
      end

      scenario 'does not require a login to see banner' do
        expect(page).not_to have_content 'You are not authorized to perform this action.'
      end

      scenario 'does include banner text' do
        expect(page).to have_content @banner.body
      end

    end

    describe 'banner does not display on grant show page' do

      before(:each) do
        @open_grant = create(:published_open_grant)
        visit grant_path(@open_grant)
      end

      scenario 'Banner only displays on home page. Grant show page does not include banner text.' do
        expect(page).not_to have_content @banner.body
      end

    end

    describe 'invisible banner' do
      before(:each) do
        @invisible_banner             = create(:invisible_banner)
        visit root_path
      end

      scenario 'visible banner displays while invisible banner does not' do
        expect(page).to have_content @banner.body
        expect(page).not_to have_content @invisible_banner.body
      end
    end
  end
end
