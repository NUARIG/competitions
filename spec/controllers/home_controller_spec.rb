require 'rails_helper'

RSpec.describe HomeController, :type => :controller do

  describe 'with a logged in System Admin User' do

    let(:grants) { Grant.all }

    describe 'GET index' do
      it "assigns all grants to @grants" do
        get :index
        expect(assigns['grants']).to eq(grants)
      end
    end
  end
end
