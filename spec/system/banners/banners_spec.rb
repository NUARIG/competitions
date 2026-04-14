# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Banners', type: :system do
  describe 'Index', js: true do
    before(:each) do
      @banner = create(:banner)
      visit root_path
    end

    describe 'user should not have access' do
      before(:each) do
        @user = create(:saml_user)
        login_as(@user, scope: :saml_user)
      end

      context '#index' do
        scenario 'displays proper error message for non-admin user' do
          visit banners_path
          expect(current_path).to eq('/')
          expect(page).to have_content('You are not authorized to perform this action.')
        end
      end
    end

    describe 'admin user' do
      before(:each) do
        @system_admin_user = create(:system_admin_saml_user)
        login_as(@system_admin_user, scope: :saml_user)
        visit root_path
      end

      context 'home page' do
        context 'header links' do
          scenario 'displays login link' do
            expect(page).to have_link 'Admin'
          end

          scenario 'displays the Banners link for admins' do
            page.find('#admin').hover
            pause
            expect(page).to have_link('Banners', href: banners_path)
            click_link 'Banners'
            pause
            expect(current_path).to eq('/banners')
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

          describe 'sorting' do
            let!(:aaa_banner) { create(:banner, body: 'aaaa, visible, created first', created_at: 10.minutes.ago) }
            let!(:zzz_banner) { create(:banner, body: 'zzzz, not visible, created last', visible: false, created_at: Time.now) }

            before do
              @banner.destroy
              visit banners_path
            end

            scenario 'default sort created_at descending' do
              within 'tr.banner:nth-child(1)' do
                expect(page).to have_text "#{zzz_banner.body}"
              end
              within 'tr.banner:nth-child(2)' do
                expect(page).to have_text "#{aaa_banner.body}"
              end
            end

            scenario 'it sorts on body text' do
              click_on(I18n.t('activerecord.attributes.banner.body'))

              within 'tr.banner:nth-child(1)' do
                expect(page).to have_text "#{aaa_banner.body}"
              end
              within 'tr.banner:nth-child(2)' do
                expect(page).to have_text "#{zzz_banner.body}"
              end

              click_on(I18n.t('activerecord.attributes.banner.body'))

              within 'tr.banner:nth-child(1)' do
                expect(page).to have_text "#{zzz_banner.body}"
              end
            end

            scenario 'it sorts on visible' do
              click_on(I18n.t('activerecord.attributes.banner.visible'))

              within 'tr.banner:nth-child(1)' do
                expect(page).to have_text "#{zzz_banner.body}"
              end
              within 'tr.banner:nth-child(2)' do
                expect(page).to have_text "#{aaa_banner.body}"
              end

              click_on(I18n.t('activerecord.attributes.banner.visible'))

              within 'tr.banner:nth-child(1)' do
                expect(page).to have_text "#{aaa_banner.body}"
              end
            end

            scenario 'it sorts on created_at' do
              click_on(I18n.t('activerecord.attributes.banner.created_at'))

              within 'tr.banner:nth-child(1)' do
                expect(page).to have_text "#{aaa_banner.body}"
              end
              within 'tr.banner:nth-child(2)' do
                expect(page).to have_text "#{zzz_banner.body}"
              end

              click_on(I18n.t('activerecord.attributes.banner.created_at'))

              within 'tr.banner:nth-child(1)' do
                expect(page).to have_text "#{zzz_banner.body}"
              end
            end
          end
        end

        context '#create' do
          scenario 'Shows error for empty body' do
            click_link 'Create New Banner'
            expect(current_path).to eq('/banners/new')
            click_button 'Save'
            expect(page).to have_content('Body is required.')
          end

          context 'visible' do
            scenario 'create a banner' do
              body = Faker::Lorem.sentence
              truncated_body = body.truncate_words(2, omission: '')

              click_link 'Create New Banner'
              expect(current_path).to eq('/banners/new')
              fill_in_trix_editor('banner_body', with: body)
              click_button 'Save'
              pause(time: 0.35)
              expect(current_path).to eq('/banners')
              expect(page).to have_content I18n.t('banners.create.visible_success')
              expect(page).to have_content(truncated_body)

              visit root_path
              expect(page).to have_content(body)
            end
          end

          context 'not visible' do
            scenario 'create a banner' do
              @body = Faker::Lorem.sentence
              truncated_body = @body.truncate_words(2, omission: '')

              click_link 'Create New Banner'
              expect(current_path).to eq('/banners/new')
              uncheck 'Visible'
              fill_in_trix_editor('banner_body', with: @body)
              click_button 'Save'
              sleep 0.25
              expect(current_path).to eq('/banners')
              expect(page).to have_content I18n.t('banners.create.not_visible_success')
              expect(page).to have_content(truncated_body)

              visit root_path
              expect(page).not_to have_content(@body)
            end
          end
        end

        context '#delete' do
          scenario 'delete a banner success' do
            truncated_body = @banner.body.truncate_words(2, omission: '')
            expect(page).to have_content(truncated_body)
            click_link 'Delete', href: banner_path(@banner)
            page.driver.browser.switch_to.alert.accept
            pause
            expect(page).not_to have_content(truncated_body)
          end
        end

        context '#edit' do
          before(:each) do
            @new_body       = Faker::Lorem.sentence
            @truncated_body = @new_body.truncate_words(2, omission: '')

            visit edit_banner_path(@banner)
          end

          context 'visible' do
            scenario 'edit a banner' do
              fill_in_trix_editor('banner_body', with: @new_body)
              click_button 'Update'
              pause
              expect(page).to have_content I18n.t('banners.update.visible_success')
              expect(current_path).to eq('/banners')
              expect(page).to have_content(@truncated_body)
            end
          end

          context 'not visible' do
            scenario 'edit a banner' do
              uncheck 'Visible'
              click_button 'Update'
              pause
              expect(page).to have_content I18n.t('banners.update.not_visible_success')
              expect(current_path).to eq('/banners')
            end
          end

          scenario 'unsuccessful edit of a banner' do
            banner_length = (@banner.body.length + 1)
            %i[arrow_right backspace].each do |key|
              banner_length.times do
                find(:xpath, "//trix-editor[@input='banner_body']").send_keys(key)
              end
            end
            click_button 'Update'
            pause
            expect(page).to have_content('Please review the following error')
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

    describe 'banner displays on other pages' do
      scenario 'banner displays on other pages' do
        @open_grant = create(:published_open_grant)
        visit grant_path(@open_grant)

        expect(page).to have_content @banner.body
      end
    end

    describe 'invisible banner' do
      before(:each) do
        @invisible_banner = create(:invisible_banner)
        visit root_path
      end

      scenario 'visible banner displays while invisible banner does not' do
        expect(page).to have_content @banner.body
        expect(page).not_to have_content @invisible_banner.body
      end
    end
  end

  describe 'PaperTrail', js: true, versioning: true do
    before(:each) do
      @banner = create(:banner)
      @system_admin_user = create(:system_admin_saml_user)
      login_as(@system_admin_user, scope: :saml_user)
      visit edit_banner_path(@banner)
    end

    it 'tracks whodunnit' do
      fill_in_trix_editor('banner_body', with: Faker::Lorem.sentence(word_count: 10))
      click_button 'Update'
      sleep(0.25)
      expect(@banner.versions.last.whodunnit).to eql(@system_admin_user.id)
    end
  end
end
