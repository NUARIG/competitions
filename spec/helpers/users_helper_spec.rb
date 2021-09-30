# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  let(:saml_user_email)       { Faker::Internet.email(domain: COMPETITIONS_CONFIG[:devise][:registerable][:saml_domains].last) }
  let(:registered_user_email) { Faker::Internet.email }

  context '#get_login_url_by_email_address' do
    it 'returns SAML login when given a configured saml user domain' do
      expect(get_login_url_by_email_address(saml_user_email)).to eql login_index_url
    end

    it 'returns Devise login url when given a configured non-saml domain' do
      expect(get_login_url_by_email_address(registered_user_email)).to eql new_registered_user_registration_url
    end
  end
end
