require 'rails_helper'

RSpec.describe 'User grant permissions requests', type: :request do
  let(:system_admin) { create(:system_admin_saml_user) }
  let(:regular_user) { create(:saml_user) }
  let(:target_user) { create(:saml_user) }

  describe 'GET /users/:user_id/grant_permissions' do
    context 'as system admin' do
      before(:each) do
        sign_in(system_admin)
      end

      it 'renders successfully' do
        grant = create(:grant, :published, publish_date: 9.days.from_now.to_date)
        create(:grant_permission, grant: grant, user: target_user, role: 'viewer')

        get user_grant_permissions_path(target_user)

        expect(response).to have_http_status(:success)
      end

      it 'paginates grant permissions with 5 items per page' do
        grants = 6.times.map do |i|
          create(:grant, :published,
                 name: "Grant #{i + 1}",
                 publish_date: (9 - i).days.from_now.to_date)
        end

        grants.each do |grant|
          create(:grant_permission, grant: grant, user: target_user, role: 'viewer')
        end

        get user_grant_permissions_path(target_user, page: 1)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Grant 1')
        expect(response.body).to include('Grant 5')
        expect(response.body).not_to include('Grant 6')

        get user_grant_permissions_path(target_user, page: 2)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Grant 6')
        expect(response.body).not_to include('Grant 1')
      end

      it 'orders by publish date desc then grant name asc' do
        newest_a = create(:grant, :published, name: 'A Latest', publish_date: 9.days.from_now.to_date)
        newest_b = create(:grant, :published, name: 'B Latest', publish_date: 9.days.from_now.to_date)
        older = create(:grant, :published, name: 'Older Grant', publish_date: 8.days.from_now.to_date)

        create(:grant_permission, grant: older, user: target_user, role: 'viewer')
        create(:grant_permission, grant: newest_b, user: target_user, role: 'viewer')
        create(:grant_permission, grant: newest_a, user: target_user, role: 'viewer')

        get user_grant_permissions_path(target_user)

        expect(response).to have_http_status(:success)
        expect(response.body.index('A Latest')).to be < response.body.index('B Latest')
        expect(response.body.index('B Latest')).to be < response.body.index('Older Grant')
      end

      it 'excludes discarded grants' do
        kept_grant = create(:grant, :published, :with_panel, name: 'Kept Grant', publish_date: 9.days.from_now.to_date)
        discarded_grant = create(:grant, :published, :with_panel, name: 'Discarded Grant', publish_date: 8.days.from_now.to_date)
        discarded_grant.discard

        create(:grant_permission, grant: kept_grant, user: target_user, role: 'viewer')
        create(:grant_permission, grant: discarded_grant, user: target_user, role: 'viewer')

        get user_grant_permissions_path(target_user)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Kept Grant')
        expect(response.body).not_to include('Discarded Grant')
      end
    end

    context 'as non-admin user' do
      it 'redirects with authorization failure' do
        sign_in(regular_user)

        get user_grant_permissions_path(target_user)

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        get user_grant_permissions_path(target_user)

        expect(response).to redirect_to(login_index_url)
      end
    end

    context 'when user is not found', with_errors_rendered: true do
      it 'returns 404' do
        sign_in(system_admin)

        get user_grant_permissions_path(user_id: 'does-not-exist')

        expect(response).to have_http_status(404)
      end
    end
  end
end
