require 'spec_helper'

describe Manager::ConfigurationsController do

  def valid_parameter_list
    {:key => 'aszxewr', :value => 'grewxte', :cat => 'test', :mime => 'text/plain'}
  end
  
  def invalid_parameter_list
  	{:key => 'aszxewr', :cat => 'test', :mime => 'text/plain'}
  end
  
  def valid_parameter_list_with_template
  	{:key => 'aszxewr', :value => 'grewxte', :cat => 'test', :mime => 'text/plain', :tpl => 55, :type => 'page'}
  end

  def valid_parameter_list_with_assoc
    {:key => 'languageItem', :value => 'grewxte', :cat => 'label', :mime => 'text/plain', :locale => 14, :type => 'locale'}
  end

  def valid_parameter_list_with_assoc_else
    {:key => 'languageItemElse', :value => 'grewxte', :cat => 'label', :mime => 'text/plain', :locale => 14, :type => 'locale'}
  end
  
  def valid_parameter_list_with_flag
  	{:key => 'aszxewr', :value => 'grewxte', :cat => 'test', :mime => 'text/plain', :tpl => 55, :flag => 'page'}
  end

  before do
    activate_authlogic

    @user = create(:validUser)
    @adminRole = create(:adminRole)
    @userHasValidRole = create(:userHasValidRole)
  end

  after do
    @user.destroy
    @adminRole.destroy
  end

  describe 'POST #create' do
    before do
    end

    after do
    end

    it "should create a new configuration item" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')
      UserSession.find.destroy
    end

    it "should not create a duplicate configuration item" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('failure')
      UserSession.find.destroy
    end
    
    it "should not create item unless all params are sent from client" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, invalid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('failure')
      UserSession.find.destroy
    end
    
    it "should create page-template association when template is provided" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list_with_template
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')
      UserSession.find.destroy
    end

    it "should not create locale items if key is duplicated" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      localeEn = create(:enUs)
      itemEn = create(:languageItem)
      itemLocaleEn = create(:languageItemEn)

      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list_with_assoc
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('failure')

      itemEn.destroy
      localeEn.destroy
      UserSession.find.destroy
    end

    it "should create locale items if key is not duplicated" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      localeEn = create(:enUs)

      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list_with_assoc_else
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      localeEn.destroy
      UserSession.find.destroy
    end
  end
  
  describe 'GET #edit' do
  	it "should raise routing error" do
  	  expect { get :edit }.to raise_error
  	end
  end

  describe 'PUT #update' do
    update_value = 'appleblossom'

    it "should successfully update metadata item" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      parsed_body.should include('data')
      new_id = parsed_body['data']['newid']

      stub_const("CompliancePlugin::ComplianceOperations", double())
      CompliancePlugin::ComplianceOperations.should_receive(:update).and_return true

      put :update, {:id => new_id, :data => {:value => update_value}}
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      UserSession.find.destroy
    end

    it "should not successfully update metadata item if there is an error" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      parsed_body.should include('data')
      new_id = parsed_body['data']['newid']
      stub_const("CompliancePlugin::ComplianceOperations", double())
      CompliancePlugin::ComplianceOperations.should_receive(:update) { raise }

      put :update, {:id => new_id, :data => {:value => update_value}}
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('failure')

      UserSession.find.destroy
    end
    
    it "should successfully update matadata item with flag" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      parsed_body.should include('data')
      new_id = parsed_body['data']['newid']
      stub_const("CompliancePlugin::ComplianceOperations", double())
      CompliancePlugin::ComplianceOperations.should_receive(:update).and_return true

      put :update, {:id => new_id, :data => {:value => update_value}, :flag => 'page'}
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      UserSession.find.destroy
    end

    it "should not successfully update matadata item with flag if there is an error" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      parsed_body.should include('data')
      new_id = parsed_body['data']['newid']
      stub_const("CompliancePlugin::ComplianceOperations", double())
      CompliancePlugin::ComplianceOperations.should_receive(:update) { raise }

      put :update, {:id => new_id, :data => {:value => update_value}, :flag => 'page'}
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('failure')

      UserSession.find.destroy
    end
  end
  
  describe 'DELETE #destroy' do
  	it "should successfully delete metadata with existing data" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

  	  post :create, valid_parameter_list
      response.should be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')

      parsed_body.should include('data')
      new_id = parsed_body['data']['newid']
  	
  	  delete :destroy, { :id => new_id }
  	  response.should be_success
  	  parsed_body = JSON.parse(response.body)
  	  expect(parsed_body['status']).to eq('success')
      UserSession.find.destroy
  	end
  	
  	it "should not delete metadata with unknown id" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)
      SiteUserStruct = Struct.new(:roles_id)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

  	  delete :destroy, { :id => 9999 }
  	  response.should be_success
  	  parsed_body = JSON.parse(response.body)
  	  expect(parsed_body['status']).to eq('failure')

      UserSession.find.destroy
  	end
  	
  	it "should not do anything if id is nil" do

  	  expect { delete :destroy, { :id => nil } }.to raise_error

    end

    it "should destroy permanently an item" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      stub_const("CompliancePlugin::ComplianceOperations", double())

      CompliancePlugin::ComplianceOperations.should_receive(:destroy_permanently).and_return true


      delete :destroy_permanently, { :id => 1 }

      response.should be_success
      parsed = JSON.parse(response.body)
      parsed['status'].should == 'success'

      UserSession.find.destroy
    end

    it "should not destroy permanently due to user not being logged in" do
      delete :destroy_permanently, { :id => 1 }

      response.should be_success
      parsed = JSON.parse(response.body)
      parsed['status'].should == 'failure'
    end
  end

  describe "POST #restore" do
    before do

    end

    after do

    end

    it "should restore" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      RoleStruct = Struct.new(:name)

      session[:accessible_appid] = 1
      session[:accessible_roleid] = 1
      Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

      stub_const("CompliancePlugin::ComplianceOperations", double())
      CompliancePlugin::ComplianceOperations.should_receive(:restore).and_return true

      post :restore, { :id => '99' }

      UserSession.find.destroy
    end
  end
end
