require 'rails_helper'

RSpec.describe 'review requests', type: :request do
  before(:example) do
    ActionMailer::Base.deliveries.clear
  end

  context 'pending' do
    before(:each) do
      @system_admin_user = create(:system_admin_user)
      sign_in @system_admin_user
    end

    let(:request) { create(:grant_creator_request) }

    context '#show' do
      it 'can be viewed' do
        get(grant_creator_request_review_path(grant_creator_request_id: request.id))
        expect(response).to have_http_status :success
      end
    end

    context '#update' do
      context 'pending status' do
        it 'does not send an email if the request is pending' do
          patch(grant_creator_request_review_path(grant_creator_request_id: request.id),
                                                  params: {
                                                    grant_creator_request: {
                                                      status: 'pending' } } )
          expect(ActionMailer::Base.deliveries.size).to eq(0)
        end
      end

      context 'approved status' do
        it 'sends approved GrantCreatorRequestReviewMailer email when approved' do
          patch(grant_creator_request_review_path(grant_creator_request_id: request.id),
                                                  params: { grant_creator_request: { status: 'approved' } })
          expect(ActionMailer::Base.deliveries.size).to eq(1)
          email = (ActionMailer::Base.deliveries).first
          expect(email.subject).to eq('CD2H Competitions - Approved Grant Creator Request')
        end
      end

      context 'rejected status' do
        it 'sends rejected GrantCreatorRequestReviewMailer email when the request is rejected' do
          patch(grant_creator_request_review_path(grant_creator_request_id: request.id),
                                                  params: { grant_creator_request: { status: 'rejected' } })
          expect(ActionMailer::Base.deliveries.size).to eq(1)
          email = (ActionMailer::Base.deliveries).first
          expect(email.subject).to eq('CD2H Competitions - Rejected Grant Creator Request')
        end
      end

      context 'invalid review' do
        it 'does not send an email' do
          allow_any_instance_of(GrantCreatorRequest).to receive(:update).and_return(false)
          put(grant_creator_request_review_path(grant_creator_request_id: request.id),
                                                  params: { grant_creator_request: { status: 'invalid_status' } })
          expect(ActionMailer::Base.deliveries.size).to eq(0)
        end
      end
    end
  end
end
