require 'rails_helper'

RSpec.describe "RegisteredUsers", type: :request do
  context 'reviewer invitation' do
    before(:example) do
      ActionMailer::Base.deliveries.clear
    end

    context 'without pending invitation' do
      it 'sends confirmation email' do
        post(registered_user_registration_path( params: { registered_user: {
                                                            email: 'test@gmailyahoo.com',
                                                            first_name: 'First',
                                                            last_name: 'Last',
                                                            password: 'password',
                                                            password_confirmation: 'password' } } ))
        new_user = User.last
        expect(new_user.first_name).to eql 'First'
        expect(new_user.confirmed_at).to be nil
        expect(ActionMailer::Base.deliveries.count).to be 1
      end
    end

    context 'with pending invitation' do
      let!(:reviewer_invitation) { create(:grant_reviewer_invitation, :registerable) }

      it 'does not send confirmation email' do
        post(registered_user_registration_path( params: { registered_user: {
                                                            email: reviewer_invitation.email,
                                                            first_name: 'First',
                                                            last_name: 'Last',
                                                            password: 'password',
                                                            password_confirmation: 'password' } } ))
        new_user = User.last
        expect(new_user.first_name).to eql 'First'
        expect(new_user.confirmed_at).not_to be nil
        expect(ActionMailer::Base.deliveries.count).to be 0
      end
    end
  end
end
