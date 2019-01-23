require "rails_helper"

RSpec.describe FieldsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/fields").to route_to("fields#index")
    end

    it "routes to #new" do
      expect(:get => "/fields/new").to route_to("fields#new")
    end

    it "routes to #show" do
      expect(:get => "/fields/1").to route_to("fields#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/fields/1/edit").to route_to("fields#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/fields").to route_to("fields#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/fields/1").to route_to("fields#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/fields/1").to route_to("fields#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/fields/1").to route_to("fields#destroy", :id => "1")
    end
  end
end
