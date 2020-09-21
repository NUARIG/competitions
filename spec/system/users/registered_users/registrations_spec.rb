# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'RegisteredUsers::Registrations', type: :system, js: true  do
  let(:valid_password)    { Faker::Lorem.characters(number: rand(Devise.password_length)) }
  let(:saml_user)         { create(:registered_user) }
  let(:registered_user)   { create(:registered_user) }
  let(:unconfirmed_user)  { create(:unconfirmed_user) }

  signup_button_text = 'Create My Account'

  before(:each) do
    visit new_registered_user_registration_path
  end

  describe 'Registration' do
    scenario 'valid information may register' do
      find_field('First Name').set('FirstName')
      find_field('Last Name').set('LastName')
      find_field('Email').set('email@example.com')
      find_field('Password').set(valid_password)
      find_field('Password confirmation').set(valid_password)
      click_button signup_button_text
      expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    end

    context 'existing users may not re-register' do
      scenario 'saml_user' do
        find_field('First Name').set('FirstName')
        find_field('Last Name').set('LastName')
        find_field('Email').set(registered_user.email)
        find_field('Password').set(saml_user.email)
        find_field('Password confirmation').set(valid_password)
        click_button signup_button_text
        expect(page).to have_content 'Email has already been taken'
      end

      scenario 'registered_user' do
        find_field('First Name').set('FirstName')
        find_field('Last Name').set('LastName')
        find_field('Email').set(registered_user.email)
        find_field('Password').set(valid_password)
        find_field('Password confirmation').set(valid_password)
        click_button signup_button_text
        expect(page).to have_content 'Email has already been taken'
      end

      scenario 'unconfirmed user' do
        find_field('First Name').set('FirstName')
        find_field('Last Name').set('LastName')
        find_field('Email').set(unconfirmed_user.uid)
        find_field('Password').set(valid_password)
        find_field('Password confirmation').set(valid_password)
        click_button signup_button_text
        expect(page).to have_content 'Email has already been taken'
      end
    end

    context 'password' do
      before(:each) do
        # visit new_registered_user_registration_path
        find_field('First Name').set('FirstName')
        find_field('Last Name').set('LastName')
        find_field('Email').set('email@example.com')
      end

      scenario 'too short fails' do
        short_password = Faker::Lorem.characters(number: Devise.password_length.min - 1)

        find_field('Password').set(short_password)
        find_field('Password confirmation').set(short_password)

        click_button signup_button_text
        expect(page).to have_content 'Password is too short'
      end

      scenario 'too long fails' do
        long_password = Faker::Lorem.characters(number: Devise.password_length.max + 1)

        find_field('Password').set(long_password)
        find_field('Password confirmation').set(long_password)

        click_button signup_button_text
        expect(page).to have_content 'Password is too long'
      end
    end
  end
end
