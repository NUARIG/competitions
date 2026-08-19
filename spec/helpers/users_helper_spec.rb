# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  let(:saml_user_email)       { Faker::Internet.email(domain: COMPETITIONS_CONFIG[:devise][:registerable][:saml_domains].last) }
  let(:registered_user_email) { Faker::Internet.email }

  context '#kept_grant_permissions' do
    let(:user)          { create(:saml_user) }
    let(:first_grant)   { create(:published_open_grant, name: 'Aardvark Award') }
    let(:second_grant)  { create(:published_open_grant, name: 'Zebra Prize') }
    let(:deleted_grant) { create(:published_open_grant, name: 'Deleted Award') }

    before(:each) do
      create(:grant_permission, grant: second_grant, user: user, role: 'editor')
      create(:grant_permission, grant: first_grant,  user: user, role: 'admin')
      create(:panel, grant: deleted_grant)
      create(:grant_permission, grant: deleted_grant, user: user, role: 'admin')
      deleted_grant.discard
    end

    it 'returns the permissions ordered by grant name' do
      expect(kept_grant_permissions(user.reload).map { |grant_permission| grant_permission.grant.name })
        .to eql [first_grant.name, second_grant.name]
    end

    it 'omits permissions on soft-deleted grants' do
      expect(kept_grant_permissions(user.reload).map(&:grant)).not_to include deleted_grant
    end

    it 'returns nothing for a user without grant permissions' do
      expect(kept_grant_permissions(create(:saml_user))).to be_empty
    end
  end

  context '#get_login_url_by_email_address' do
    it 'returns SAML login when given a configured saml user domain' do
      expect(get_login_url_by_email_address(saml_user_email)).to eql login_index_url
    end

    it 'returns Devise login url when given a configured non-saml domain' do
      expect(get_login_url_by_email_address(registered_user_email)).to eql new_registered_user_registration_url
    end
  end
end
