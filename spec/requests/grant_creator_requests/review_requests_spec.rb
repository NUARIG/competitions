require 'rails_helper'

RSpec.describe 'review requests', type: :request do

  let(:grant_creator_request) { create(:grant_creator_request) }
  let(:grant_creator)         { create(:grant_creator_user) }
  let(:system_admin_user)     { create(:system_admin_user) }
  let(:another_user)          { create(:user) }

  context '#index' do
    context 'system_admin' do
      it 'renders' do
        sign_in system_admin_user
        get(grant_creator_requests_path)
        expect(response).to have_http_status :success
      end
    end

    context 'a requester' do
      it 'redirects' do
        sign_in grant_creator_request.requester
        get(grant_creator_requests_path)
        expect(response).to have_http_status :redirect
      end
    end

    context 'another_user' do
      it 'redirects' do
        sign_in another_user
        get(grant_creator_requests_path)
        expect(response).to have_http_status :redirect
      end
    end
  end

  context '#new' do
    context 'user who is not a grant_creator' do
      it 'renders' do
        sign_in another_user
        get(new_grant_creator_request_path)
        expect(response).to have_http_status :success
      end
    end

    context 'grant_creator' do
      it 'redirects' do
        sign_in grant_creator
        get(new_grant_creator_request_path)
        expect(response).to have_http_status :redirect
        expect(response).to redirect_to profile_path
      end
    end
  end

  context '#edit' do
    context 'requester' do
      it 'renders' do
        sign_in grant_creator_request.requester
        get(edit_grant_creator_request_path(grant_creator_request))
        expect(response).to have_http_status :success
      end
    end

    context 'system_admin' do
      it 'renders' do
        sign_in system_admin_user
        get(edit_grant_creator_request_path(grant_creator_request))
        expect(response).to have_http_status :success
      end
    end

    context 'another user' do
      it 'redirects' do
        sign_in another_user
        get(edit_grant_creator_request_path(grant_creator_request))
        expect(response).to have_http_status :redirect
      end
    end
  end

  context 'review' do
    before(:example) do
      ActionMailer::Base.deliveries.clear
    end

    context 'pending' do
      before(:each) do
        sign_in system_admin_user
      end

      context '#show' do
        it 'can be viewed' do
          get(grant_creator_request_review_path(grant_creator_request_id: grant_creator_request.id),
                                                  params: { id: grant_creator_request.id } )
          expect(response).to have_http_status :success
        end
      end

      context '#update' do
        context 'pending status' do
          it 'does not send an email if the request is pending' do
            patch(grant_creator_request_review_path(grant_creator_request_id: grant_creator_request.id),
                                                    params: {
                                                      id: grant_creator_request.id,
                                                      grant_creator_request: {
                                                        status: 'pending' } } )
            expect(ActionMailer::Base.deliveries.size).to eq(0)
          end
        end

        context 'approved status' do
          it 'sends approved GrantCreatorRequestReviewMailer email when approved' do
            patch(grant_creator_request_review_path(grant_creator_request_id: grant_creator_request.id),
                                                    params: { id: grant_creator_request.id, grant_creator_request: { status: 'approved' } })
            expect(ActionMailer::Base.deliveries.size).to eq(1)
            email = (ActionMailer::Base.deliveries).first
            expect(email.subject).to eq("#{COMPETITIONS_CONFIG[:application_name]}: Approved Grant Creator Request")
          end
        end

        context 'rejected status' do
          it 'sends rejected GrantCreatorRequestReviewMailer email when the request is rejected' do
            patch(grant_creator_request_review_path(grant_creator_request_id: grant_creator_request.id),
                                                    params: { id: grant_creator_request.id, grant_creator_request: { status: 'rejected' } })
            expect(ActionMailer::Base.deliveries.size).to eq(1)
            email = (ActionMailer::Base.deliveries).first
            expect(email.subject).to eq("#{COMPETITIONS_CONFIG[:application_name]}: Rejected Grant Creator Request")
          end
        end

        context 'invalid review' do
          it 'does not send an email' do
            allow_any_instance_of(GrantCreatorRequest).to receive(:update).and_return(false)
            put(grant_creator_request_review_path(grant_creator_request_id: grant_creator_request.id),
                                                    params: { id: grant_creator_request.id, grant_creator_request: { status: 'invalid_status' } })
            expect(ActionMailer::Base.deliveries.size).to eq(0)
          end
        end
      end
    end
  end
end
