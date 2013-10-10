require 'spec_helper'

describe Manager::UsersController do

  before do
    @user = create(:validUser)
    @role = create(:adminRole)
    @devRole = create(:developerRole)
    @userHasRole = create(:userHasValidRole)
    @siteUser = create(:site_user)

    activate_authlogic
  end

  after do
    @user.destroy
    @role.delete
    @devRole.delete
    @siteUser.destroy
  end

  describe "POST #create" do
    it "should create user" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      newUser = {
          :login => 'test',
          :password => 'testpass',
          :password_confirmation => 'testpass',
          :email => "test@test.com"
      }

      RoleStruct = Struct.new(:id, :name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new(1, 'admin')

      UserMailer.stub(:activate_account_email) { UserMailer }
      UserMailer.should_receive(:deliver).and_return true

      post :create, { :newUser => newUser, :newRole => 1 }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('success')

      UserSession.find.destroy
    end

    it "should not create user if input data are corrupt" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      newUser = {
          :login => 'test',
          :password => 'testpass',
          :password_confirmation => 'testpass',
          :email => "testtest.com"
      }

      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, { :newUser => newUser, :newRole => 1 }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end
  end

  describe "PUT #update" do
    before do
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)
    end

    it "should update user email" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      updateInfos = {
          'email' => '123456@yahoo.com'
      }

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :update, { :id => 1, :oldPassword => '', :user => updateInfos }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('success')

      UserSession.find.destroy
    end

    it "should not update if user id is invalid" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      updateInfos = {
          'email' => '123456@yahoo.com'
      }

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :update, { :id => 0, :oldPassword => '', :user => updateInfos }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end

    it "should not update if user email is invalid" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      updateInfos = {
          'email' => '123456yahoo.com'
      }

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :update, { :id => 1, :oldPassword => '', :user => updateInfos }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end

    it "should update user infos when he/she provides old password" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      updateInfos = {
          'email' => '123456@yahoo.com',
          'password' => 'changedpassword',
          'password_confirmation' => 'changedpassword'
      }

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :update, { :id => 1, :oldPassword => 'password', :user => updateInfos }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('success')

      UserSession.find.destroy
    end

    it "should not update user infos when he/she provides wrong old password" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      updateInfos = {
          'email' => '123456@yahoo.com',
          'password' => 'changedpassword',
          'password_confirmation' => 'changedpassword'
      }

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :update, { :id => 1, :oldPassword => 'wrongpassword', :user => updateInfos }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end

    it "should not update user infos when he/she provides old password but email and others are invalid" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      updateInfos = {
          'email' => '123456yahoo.com',
          'password' => 'changepassword',
          'password_confirmation' => 'changedpassword'
      }

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :update, { :id => 1, :oldPassword => 'password', :user => updateInfos }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end

    it "should not update user infos when user id is invalid" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      updateInfos = {
          'email' => '123456yahoo.com',
          'password' => 'changepassword',
          'password_confirmation' => 'changedpassword'
      }

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :update, { :id => 0, :oldPassword => 'password', :user => updateInfos }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end
  end

  describe "PUT #update_role" do
    before do
      RoleStruct = Struct.new(:name, :id)
    end

    after do

    end

    it "should update role" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      SiteUser.should_receive(:update).and_return true

      put :update_role, { :id => 1, :role => 2, :roleOrig => 1 }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('success')

      UserSession.find.destroy
    end

    it "should not update role if role is not found" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin', 1)

      put :update_role, { :id => 1, :role => 0 }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end

    it "should not update role if there's an error" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin', 1)

      SiteUser.should_receive(:first) { raise }
      put :update_role, { :id => 1, :role => 0 }
      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end
  end

  describe "DELETE #destroy" do
    before do
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)
    end

    after do

    end

    it "should destroy user infos" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1

      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      put :destroy, { :id => 1 }

      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('success')

    end
  end

  describe "PUT #update_self" do
    before do
      session[:accessible_userid] = 1
      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
    end

    after do
    end

    it "should update self" do
      user = build(:validUser)
      UserSession.create({ :login => user.login, :password => user.password })

      put :update_self, { :data => {'email' => 'test@user.com'}}

      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('success')

      UserSession.find.destroy
    end

    it "should not update self if there's an error" do
      user = build(:validUser)
      UserSession.create({ :login => user.login, :password => user.password })

      session[:accessible_userid] = 9999
      put :update_self, { :data => {'email' => 'test@user.com'}}

      response.should be_success
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq('failure')

      UserSession.find.destroy
    end
  end

  describe "GET #activate_user" do
    before do
      @inactiveUser = create(:inactiveUser)
    end

    after do
      @inactiveUser.destroy
    end

    it "should activate user" do
      get :activate_user, { :code => Digest::SHA256.hexdigest("6") }

      response.code.should == '302'
    end

    it "should not activate user if user is activated" do
      get :activate_user, { :code => Digest::SHA256.hexdigest("1") }

      response.code.should == '302'
    end
  end

  describe "POST #create_user_only" do
    before do

    end

    after do

    end

    it "should create user only" do
      user = build(:validUser)
      UserSession.create({ :login => user.login, :password => user.password })

      UserStruct = Struct.new(:id)

      # User.stub(:new) { user }
      UserMailer.stub(:activate_account_email) {UserMailer}
      controller.request.should_receive(:host_with_port).and_return "http://test.host"
      Digest::SHA256.should_receive(:hexdigest).and_return "123"
      UserMailer.should_receive(:deliver).and_return true

      post :create_user_only, { :newUser => { :login => 'lequack', :password => '123456', :password_confirmation => '123456', :email => 'test@test.com' } }

      response.should be_success
      parsed = JSON.parse(response.body)
      parsed['status'].should == 'success'

      UserSession.find.destroy
    end

    it "should not create user only when infos are invalid" do
      user = build(:validUser)
      UserSession.create({ :login => user.login, :password => user.password })

      UserStruct = Struct.new(:id)

      # User.stub(:new) { user }

      post :create_user_only, { :newUser => { :login => 'lequack', :password => '123456', :password_confirmation => '12356', :email => 'test@test.com' } }

      response.should be_success
      parsed = JSON.parse(response.body)
      parsed['status'].should == 'failure'

      UserSession.find.destroy
    end
  end

end