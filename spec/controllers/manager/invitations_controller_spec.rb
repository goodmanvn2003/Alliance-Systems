require 'spec_helper'

describe Manager::InvitationsController do
  describe "POST #create" do

    it "should create invitation" do
      post :create

      response.should be_success
    end

  end

  describe "PUT #update" do

    it "should update invitation" do
      put :update, { :id => 1 }

      response.should be_success
    end

  end

  describe "DELETE #destroy" do

    it "should delete invitation" do
      delete :destroy, { :id => 1 }

      response.should be_success
    end

  end
end