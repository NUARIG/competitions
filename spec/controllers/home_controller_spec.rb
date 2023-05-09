require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  let!(:grant) { create(:published_open_grant_with_users) }
  let(:grants) { Grant.all }

  describe 'with a logged in System Admin User' do
    describe 'GET index' do
      it 'assigns all grants to @grants' do
        get :index
        expect(assigns[:grants]).to match_array([grant])
      end
    end
  end
end
