require 'rails_helper'

RSpec.describe BannersController, type: :controller do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe 'with a logged in System Admin User' do
    before(:each) do
      login_system_admin_saml_user
    end

    let(:valid_attributes) {
      { body: "THIS IS A BANNER", visible: true }
    }

    let(:invalid_attributes) {
      { body: "", visible: true }
    }

    describe 'GET index' do

      before(:each) do
        @banner_index = FactoryBot.create(:banner)
      end

      let(:banners) { Banner.all }

      it "successfully loads the index page" do
        get :index
        expect(response).to be_successful
        expect(response.status).to eq 200
        expect(response).to render_template :index
      end
    end

    describe 'GET new' do
      it "assigns a new banner as @banner" do
        get :new, params: {}
        expect(assigns(:banner)).to be_a_new(Banner)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it "creates a new Banner" do
          expect {
            post :create, params: { banner: valid_attributes }
          }.to change(Banner, :count).by(1)
        end

        it "assigns a newly created banner as @banner" do
          post :create, params: { banner: valid_attributes }
          expect(assigns(:banner)).to be_a(Banner)
          expect(assigns(:banner)).to be_persisted
        end

        it "redirects to the created banner" do
          post :create, params: {banner: valid_attributes }
          expect(response).to redirect_to(banners_path)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved banner as @banner" do
          post :create, params: {:banner => invalid_attributes}
          expect(assigns(:banner)).to be_a_new(Banner)
        end

        it "re-renders the 'new' template" do
          post :create, params: {:banner => invalid_attributes}
          expect(response).to render_template("new")
        end
      end
    end

    describe "GET edit" do
      it "assigns the requested banner as @banner" do
        banner = Banner.create! valid_attributes
        get :edit, params: {:id => banner.to_param}
        expect(assigns(:banner)).to eq(banner)
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        let(:new_attributes) {
            { body: 'This is the NEW banner body!' }
          }

        before do
          @banner_update = Banner.create! valid_attributes
        end

        it "updates the requested banner" do
          put :update, params: {id: @banner_update.to_param, banner: new_attributes}
          @banner_update.reload
          expect(@banner_update.body).to eq('This is the NEW banner body!')
        end

        it "assigns the requested banner as @banner" do
          put :update, params: {:id => @banner_update.to_param, :banner => valid_attributes}
          expect(assigns(:banner)).to eq(@banner_update)
        end

        it "redirects to the banner" do
          put :update, params: {:id => @banner_update.to_param, :banner => valid_attributes}
          expect(response).to redirect_to(banners_path)
        end
      end

      describe "with invalid params" do
        it "assigns the banner as @banner" do
          banner = Banner.create! valid_attributes
          put :update, params: {:id => banner.to_param, :banner => invalid_attributes}
          expect(assigns(:banner)).to eq(banner)
        end

        it "re-renders the 'edit' template" do
          banner = Banner.create! valid_attributes
          put :update, params: {:id => banner.to_param, :banner => invalid_attributes}
          expect(response).to render_template("edit")
        end
      end

    end

    describe "DELETE destroy" do

      before do
        @banner_nil = Banner.create! valid_attributes
      end

      describe 'provides error messages for deleting a banner.' do
        it "cannot destroy a nil banner" do
          allow_any_instance_of(Banner).to receive(:nil?).and_return(true)
          delete :destroy, params: {:id => @banner_nil.to_param}
          expect(flash[:alert]).to have_content('Banner could not be found.')
        end

        it "redirects to the banners list" do
          delete :destroy, params: {:id => @banner_nil.to_param}
          expect(response).to redirect_to(banners_path)
        end

        it 'last else catch all' do
          allow_any_instance_of(Banner).to receive(:destroy).and_return(false)
          delete :destroy, params: {:id => @banner_nil.to_param}
          expect(flash[:alert]).to have_content('Unable to delete this banner.')
        end
      end

      describe 'deletes a deletable banner.' do
        before do
          @banner_destroy = Banner.create! valid_attributes
        end

        it "destroys the requested banner" do
          expect {
            delete :destroy, params: {:id => @banner_destroy.to_param}
          }.to change(Banner, :count).by(-1)
        end

        it "redirects to the banners list" do
          delete :destroy, params: {:id => @banner_destroy.to_param}
          expect(response).to redirect_to(banners_path)
        end
      end
    end
  end
end
