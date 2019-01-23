require 'rails_helper'

RSpec.describe "Fields", type: :request do
  describe "GET /fields" do
    it "works! (now write some real specs)" do
      get fields_path
      expect(response).to have_http_status(200)
    end
  end
end
