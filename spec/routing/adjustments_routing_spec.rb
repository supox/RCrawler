require "spec_helper"

describe AdjustmentsController do
  describe "routing" do

    it "routes to #index" do
      get("/adjustments").should route_to("adjustments#index")
    end

    it "routes to #new" do
      get("/adjustments/new").should route_to("adjustments#new")
    end

    it "routes to #show" do
      get("/adjustments/1").should route_to("adjustments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/adjustments/1/edit").should route_to("adjustments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/adjustments").should route_to("adjustments#create")
    end

    it "routes to #update" do
      put("/adjustments/1").should route_to("adjustments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/adjustments/1").should route_to("adjustments#destroy", :id => "1")
    end

  end
end
