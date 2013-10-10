require 'spec_helper'

describe Manager::SiteUsersController do
  before do
    activate_authlogic
  end

  after do

  end

  describe "POST #create" do
    before do
      controller.stub(:is_current_accessible?).and_return true

      @user = create(:validUser)
      @role = create(:adminRole)
      @site = create(:site)
    end

    after do
      @user.destroy
      @role.destroy
      @site.destroy
    end

    it "should create site user" do
      session[:accessible_appid] = 1

      post :create, { :user => 1, :role => 1 }

      response.should be_success
      parsed = JSON.parse(response.body)
      parsed['status'].should == 'success'
    end
  end

  describe "DELETE #destroy" do
    before do
      controller.stub(:is_current_accessible?).and_return true
      create(:site_user)
    end

    after do

    end

    it "should destroy site user" do
      session[:accessible_appid] = 1

      delete :destroy, { :id => 1, :groupId => 1 }

      response.should be_success
      parsed = JSON.parse(response.body)
      parsed['status'].should == 'success'
    end

    it "should not destroy site user if appid is nil" do
      delete :destroy, { :id => 1, :groupId => 1 }

      response.should be_success
      parsed = JSON.parse(response.body)
      parsed['status'].should == 'failure'
    end
  end

  describe "test private methods" do
    before do
      @user = create(:validUser)
    end

    after do
      @user.destroy
    end

    it "should get current user" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      controller.send(:current_user).should_not be_nil

      UserSession.find.destroy
    end

    it "should check if user can access" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      RoleStruct = Struct.new(:id, :name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).and_return RoleStruct.new(1, 'admin')

      controller.send(:is_current_accessible?).should be_nil

      UserSession.find.destroy
    end
  end

end
