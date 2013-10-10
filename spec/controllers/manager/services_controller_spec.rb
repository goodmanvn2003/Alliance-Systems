require 'spec_helper'

describe Manager::ServicesController do

  before  do
  	controller.stub(:ensure_login).and_return true
    @user = create(:validUser)
    @role = create(:adminRole)
    @devRole = create(:developerRole)
    @devUser = create(:validDevUser)
    @userHasRole = create(:userHasValidRole)
    @userHasDevRole = create(:userHasDevRole)
    activate_authlogic
  end

  after do
    @user.destroy
    @devUser.destroy
    @role.destroy
    @devRole.destroy
  end

  it "should fetch nothing with invalid id" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    get :fetch_one_by_id, {:id => '-1'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    parsed_body.should be_empty

    UserSession.find.destroy
  end

  it "should not fetch anything with invalid id if user is not logged in" do

    get :fetch_one_by_id, {:id => '-1'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    parsed_body.should be_empty

  end

  it "should fetch nothing with key and category" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    get :fetch_one_by_key, {:key => 'abc', :cat => 'blah'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    parsed_body.should be_empty

    UserSession.find.destroy
  end

  it "should not fetch anything with key and category if user is not logged in" do
    get :fetch_one_by_key, {:key => 'abc', :cat => 'blah'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    parsed_body.should be_empty
  end

  it "should fetch one by value" do
    UserSession.create({ :login => @user.login, :password => @user.password })
    @enUs = create(:enUs)

    session[:accessible_appid] = 1

    get :fetch_one_by_value, { :value => 'en_US', :cat => 'locale' }

    response.should be_success
    parsed_body = JSON.parse(response.body)
    parsed_body.should_not be_empty

    @enUs.destroy
    UserSession.find.destroy
  end

  #it "should fetch nothing with invalid category" do
  #  get :fetch_all_by_cat, {:cat => 'blah'}

  #  response.should be_success
  #  parsed_body = JSON.parse(response.body)
  #  parsed_body.should be_empty
  #end

  it "should not do anything with invalid item and template ids" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    get :set_active_item, {:destId => '10', :srcId => '20'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('success')
    expect(parsed_body['message']).to eq('nothing to do')

    get :remove_active_item, {:destId => '391624', :srcId => '2'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('success')
    expect(parsed_body['message']).to eq('nothing to do')

    UserSession.find.destroy
  end

  it "should not do anything with invalid item and template ids and user is not logged in" do

    get :set_active_item, {:destId => '10', :srcId => '20'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('failure')

    get :remove_active_item, {:destId => '391624', :srcId => '2'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('failure')

  end

  it "should return success with valid item and template ids" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    get :set_active_item, {:destId => '2', :srcId => '1'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('success')
    expect(parsed_body['message']).to eq('nothing to do')

    UserSession.find.destroy
  end

  it "should return failure with valid item and template ids if user is not logged in" do
    get :set_active_item, {:destId => '2', :srcId => '1'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('failure')
  end
  
  it "should remove association item with valid item and template ids" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    get :remove_active_item, {:destId => '2', :srcId => '1'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('success')
    expect(parsed_body['message']).to eq('nothing to do')

    UserSession.find.destroy
  end

  it "should not remove association item with valid item and template ids if user is not logged in" do
    get :remove_active_item, {:destId => '2', :srcId => '1'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('failure')
  end

  it "should not do anything with invalid template ids" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    get :get_items_of_template, {:tpl => '391624'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('success')
    expect(parsed_body['message']).to eq('nothing to do')

    UserSession.find.destroy
  end

  it "should not fail with invalid template ids and user is not logged in" do
    get :get_items_of_template, {:tpl => '391624'}

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('failure')
  end
  
  #it "should get status of app from podio" do
  #  AbstractApplication.should_receive(:app_exists?).at_least(:once).and_return true
  
  #	get :get_podio_app_status, {:appid => "4603777"}
  	
  #	response.should be_success
  #	parsed_body = JSON.parse(response.body)
  #	expect(parsed_body['status']).to eq("success")
  #	parsed_body['message'].should_not be_empty
  	
  #	get :get_podio_app_status, {:appid => "2128392"}
  	
  #	response.should be_success
  #	parsed_body = JSON.parse(response.body)
  #	expect(parsed_body['status']).to eq("success")
  #	parsed_body['message'].should_not be_empty
  #end

  #it "processes service account" do
  #	userInfoObj = {
	#  	"value" => "podio01@gant.net.au",
	#	"cat" => "config",
	#	"mime" => "text/plain"
  #	}
  #	userPassObj = {
	#  	"value" => "nlkk123456",
	#	"cat" => "config",
	#	"mime" => "text/plain"
  #	}
  
  #	post :update_or_create_podio_service_account, {:userObject => userInfoObj, :passObject => userPassObj}
  	
  #	response.should be_success
  #	parsed_body = JSON.parse(response.body)
  #	expect(parsed_body['status']).to eq("success")
  # end
  
  it "can get files for folder" do
    UserSession.create({ :login => @user.login, :password => @user.password })

  	get :get_files_for_folders
  	
  	response.should be_success
  	parsed_body = JSON.parse(response.body)
  	expect(parsed_body).not_to be_empty

    UserSession.find.destroy
  end

  it "cannot get files for folder if user is not logged in" do
    get :get_files_for_folders

    response.should be_success
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['status']).to eq('failure')
  end
  
  #it "checks service account authenticity if the account is valid" do
  #	testUser = "podio01@gant.net.au"
  #	testPass = "nlkk123456"
  	
  #	AbstractApplication.should_receive(:test_authentication?).at_least(:once).and_return true
  	
  #	get :check_user_login, {:user => testUser, :pass => testPass}
  	
  #	response.should be_success
  #	parsed_body = JSON.parse(response.body)
  #	expect(parsed_body['status']).to eq("success")
  #end
  
  #it "checks service account authenticity if the account is not valid" do
  #	testUser = "hacker@gant.net.au"
  #	testPass = "hacker123456"
  	
  #	AbstractApplication.should_receive(:test_authentication?).at_least(:once).and_return false
  	
  #	get :check_user_login, {:user => testUser, :pass => testPass}
  	
  #	response.should be_success
  #	parsed_body = JSON.parse(response.body)
  #	expect(parsed_body['status']).to eq("failure")
  #end

  #it "should get list of user's organizations" do

  #  AbstractOrganization.should_receive(:get_list_of_organizations).at_least(:once).and_return [{:id => 'null', :name => 'null', :spaces => [{ :space_id => 'null', :space_name => 'null' }] }]
  #  get :get_list_of_organizations_of_user

  #  response.should be_success
  #  parsed = JSON.parse(response.body)
  #  parsed.should_not be_nil

  #end

  #it "should get a list of apps from space" do

  #  AbstractApplication.should_receive(:get_apps_list_by_space).at_least(:once).and_return [{:id => 'null', :name => 'null', :description => 'null', :icon => 'null' }]

  #  get :get_list_of_apps_from_workspace, {:space => '123456'}
  #  response.should be_success
  #  parsed = JSON.parse(response.body)
  #  parsed.should_not be_nil

  #end

  #it "should set current podio workspace if related key exists" do

  #  get :set_current_podio_workspace, {:space => '123456'}
  #  response.should be_success
  #  parsed = JSON.parse(response.body)
  #  expect(parsed['status']).to eq("success")

  #end

  #it "should create current podio workspace if related key doesn't exists" do

  #  @currentWksp = create(:currentworkspace)

  #  get :set_current_podio_workspace, {:space => '123456'}
  #  response.should be_success
  #  parsed = JSON.parse(response.body)
  #  expect(parsed['status']).to eq("success")

  #  @currentWksp.destroy

  #end

  #it "should get current podio workspace if related key exists" do

  #  @currentWksp = create(:currentworkspace)

  #  get :get_current_podio_workspace
  #  response.should be_success
  #  parsed = JSON.parse(response.body)
  #  expect(parsed['status']).to eq("success")

  #  @currentWksp.destroy

  #end

  #it "should not get current podio workspace if related key doesn't exist" do

  #  get :get_current_podio_workspace
  #  response.should be_success
  #  parsed = JSON.parse(response.body)
  #  expect(parsed['status']).to eq("failure")

  #end

  it "should get list of metadata by cat" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    get :get_list_of_configuration_items_by_cat, {:cat => 'config'}
    response.should be_success
    response.body.should_not be_nil

    UserSession.find.destroy
  end

  it "should not get list of metadata by cat if user is not logged in" do
    get :get_list_of_configuration_items_by_cat, {:cat => 'config'}
    response.should be_success
    parsed = JSON.parse(response.body)

    parsed.should be_empty
  end

  it "should get list of configuration by association" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    Metadata.should_receive(:find).at_least(:once).and_return double()
    Metadata.should_receive(:all).at_least(:once).and_return Array.new(3,true)

    get :get_list_of_configuration_items_by_assoc, {:cat => 'label', :item => 1}
    response.should be_success
    response.body.should_not be_empty

    UserSession.find.destroy
  end

  it "should get list of configuration by association in reverse" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    Metadata.should_receive(:find).at_least(:once).and_return double()
    MetadataAssociation.should_receive(:find_all_by_destId).at_least(:once).and_return Array.new(3,true)
    Metadata.should_receive(:all).at_least(:once).and_return Array.new(3,true)

    get :get_list_of_configuration_items_by_assoc_in_reverse, {:cat => 'label', :item => 1}
    response.should be_success
    response.body.should_not be_empty

    UserSession.find.destroy
  end

  it "should not get list of configuration by association in reverse if user is not logged in" do
    get :get_list_of_configuration_items_by_assoc_in_reverse, {:cat => 'label', :item => 1}
    response.should be_success
    response.body.should_not be_empty
  end

  it "should not get list of configuration by association if user is not logged in" do

    get :get_list_of_configuration_items_by_assoc, {:cat => 'label', :item => 1}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed.should be_empty

  end

  it "should not send password recovery email if user is logged in" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    post :send_forgot_password_email, {:email => 'admin@host.com'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == "failure"

    UserSession.find.destroy
  end

  it "should send password recovery email if user is not logged in" do

    mailer = double("mailer")
    mailer.stub(:deliver)
    UserMailer.should_receive(:reset_passwords_email).and_return(mailer)

    post :send_forgot_password_email, {:email => 'admin@host.com'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == "success"

  end

  it "should not send password recovery email if user doesn't have such email" do

    User.should_receive(:find_by_email).and_return nil

    post :send_forgot_password_email, {:email => 'admin@host.com'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == "failure"

  end

  it "should not send password recovery email if mailer configuration is corrupt" do

    UserMailer.stub(:reset_passwords_email).stub(:deliver).and_return double()

    post :send_forgot_password_email, {:email => 'admin@host.com'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == "failure"

  end

  it "should not change passwords if user is logged in" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    post :do_change_forgot_password, {:requestCode => '123456', :newPassword => '123456', :newPasswordConfirmation => '382838'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'failure'

    UserSession.find.destroy
  end

  it "should change passwords if user is not logged in and information are correct" do

    User.should_receive(:find_by_perishable_token).and_return @user

    post :do_change_forgot_password, {:requestCode => '123456', :newPassword => '123456', :newPasswordConfirmation => '123456'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'success'

  end

  it "should fail to change passwords if user is not logged in and information are incorrect" do

    User.should_receive(:find_by_perishable_token).and_return @user

    post :do_change_forgot_password, {:requestCode => '123456', :newPassword => '123456', :newPasswordConfirmation => '654321'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'failure'

  end

  it "should fail to change passwords if such user is not found" do

    post :do_change_forgot_password, {:requestCode => 'unknowncode', :newPassword => '123456', :newPasswordConfirmation => '654321'}
    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'failure'

  end

  it "should get a list of users for group" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    get :get_list_users_by_group, {:groupId => 1}
    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('success')

    UserSession.find.destroy
  end

  it "should not get a list of users for group if user is not admin" do
    UserSession.create({ :login => @devUser.login, :password => @devUser.password })

    get :get_list_users_by_group, {:groupId => 1}
    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('failure')

    UserSession.find.destroy
  end

  it "should not a list of users for group if user is not logged in" do

    get :get_list_users_by_group, {:groupId => 1}
    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('failure')

  end

  it "should get a list of user's sites" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    get :get_users_sites

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('success')

    UserSession.find.destroy
  end

  it "should not get a list of user's sites if user is not logged in properly" do
    get :get_users_sites

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('failure')
  end

  it "should get site information" do
    UserSession.create({ :login => @user.login, :password => @user.password })
    @site = create(:site)
    @siteMeta = create(:siteMeta)

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    get :get_site_information, { :siteid => 1, :key => 'preferences' }

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('success')

    @site.destroy
    @siteMeta.destroy
    UserSession.find.destroy
  end

  it "should create site" do
    UserSession.create({ :login => @user.login, :password => @user.password })
    @site = create(:site)
    @siteMeta = create(:siteMeta)

    RoleStruct = Struct.new(:id, :name)
    SiteStruct = Struct.new(:id, :sites_id)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new(1, 'admin')

    site = SiteStruct.new(1, '')
    Site.should_receive(:create).at_least(:once).and_return site
    Site.stub(:update) { site }
    Role.should_receive(:find_by_name).and_return RoleStruct.new(1, 'admin')
    SiteUser.should_receive(:create).and_return true

    Metadata.should_receive(:create).at_least(:once).and_return true
    Dir.stub(:mkdir).and_return true

    post :create_site, { :name => 'a site', :description => 'a site description' }

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('success')

    @site.destroy
    @siteMeta.destroy
    UserSession.find.destroy
  end

  it "should delete site" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    @site = create(:site)
    @siteMeta = create(:siteMeta)

    RoleStruct = Struct.new(:id, :name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new(1, 'admin')

    delete :delete_site, { :id => 1 }

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('success')

    UserSession.find.destroy
  end

  it "should generate valid captcha" do
    request.should_receive(:xhr?).at_least(:once).and_return true

    get :generate_captcha

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('success')
  end

  it "should not generate captcha if request is non-xhr" do
    request.should_receive(:xhr?).at_least(:once).and_return false

    get :generate_captcha

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('failure')
  end

  it "should verify captcha successfully" do
    request.should_receive(:xhr?).at_least(:once).and_return true
    session[:captcha_answer] = '35'

    post :verify_captcha, { :captcha => '35' }

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('passed')
  end

  it "should show that captcha is expired if session is no longer valid" do
    request.should_receive(:xhr?).at_least(:once).and_return true
    session[:captcha_answer] = nil

    post :verify_captcha, { :captcha => '35' }

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('failure')
  end

  it "should validate captcha successfully and find that captcha is invalid if input data don't match" do
    request.should_receive(:xhr?).at_least(:once).and_return true
    session[:captcha_answer] = '1'

    post :verify_captcha, { :captcha => '35' }

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('failed')
  end

  it "should not allow non-xhr request when validating captcha" do
    request.should_receive(:xhr?).at_least(:once).and_return false

    post :verify_captcha, { :captcha => '35' }

    response.should be_success
    parsed = JSON.parse(response.body)
    expect(parsed['status']).to eq('failure')
  end

  it "should get list of users by filter" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:id, :name)
    SiteUserStruct = Struct.new(:roles_id)
    user = build(:validUser)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new(1, 'admin')

    User.stub(:select) { User }
    User.should_receive(:where).and_return []
    SiteUser.should_receive(:find_all_by_sites_id).and_return SiteUserStruct.new(1)
    User.should_receive(:find_by_email).and_return double()

    get :get_list_of_all_users_by_filter, { :email => 'test@test.com' }

    UserSession.find.destroy
  end

  it "should send invitation email to user" do
    site = build(:siteMeta)
    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    UserSession.create({ :login => @user.login, :password => @user.password })
    Metadata.should_receive(:first).and_return site
    Invitation.should_receive(:create!).and_return true
    ActiveSupport::JSON.should_receive(:decode).and_return "aname"
    UserMailer.stub(:invite_email) { UserMailer }
    UserMailer.should_receive(:deliver).and_return true

    post :send_invitation_email_to_user, { :email => 'test@test.com' }

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'success'

    UserSession.find.destroy
  end

  it "should not send invitation email to user if there is a problem" do
    site = build(:siteMeta)
    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    UserSession.create({ :login => @user.login, :password => @user.password })
    Metadata.should_receive(:first).and_return site
    Invitation.should_receive(:create!).and_return true

    post :send_invitation_email_to_user, { :email => 'test@test.com' }

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'failure'

    UserSession.find.destroy
  end

  it "should not send invitation to other user if current user is not logged in" do
    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    post :send_invitation_email_to_user, { :email => 'test@test.com' }

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'failure'
  end

  it "should get user assigned roles for profile" do
    siteUser = build(:site_user)

    UserSession.create({ :login => @user.login, :password => @user.password })

    SiteUser.should_receive(:all).and_return [siteUser]
    Role.should_receive(:find).at_least(:once).and_return nil

    get :get_users_assigned_roles_for_profile

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'success'

    UserSession.find.destroy
  end

  it "should not get user assigned roles for profile if user is not logged in" do
    siteUser = build(:site_user)

    get :get_users_assigned_roles_for_profile

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'failure'

  end

  it "should give errors when trying to get user assigned roles" do
    siteUser = build(:site_user)

    UserSession.create({ :login => @user.login, :password => @user.password })

    SiteUser.should_receive(:all).and_return [siteUser]
    Role.should_receive(:find).at_least(:once).and_return double()

    get :get_users_assigned_roles_for_profile

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'failure'

    UserSession.find.destroy
  end

  it "should get a list of user assigned role" do
    siteUser = build(:site_user)
    role = build(:adminRole)
    UserSession.create({ :login => @user.login, :password => @user.password })

    SiteUser.should_receive(:all).and_return [siteUser]
    Role.should_receive(:find).at_least(:once).and_return [role]

    get :get_users_assigned_roles, { :sites_id => 1 }

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'] = 'success'

    UserSession.find.destroy
  end

  it "should set users assigned role" do
    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    UserSession.create({ :login => @user.login, :password => @user.password })

    SiteUser.should_receive(:first).and_return nil

    put :set_user_assigned_role, { :users_id => 1, :roles_id => 2 }

    response.should be_success
    parsed = JSON.parse(response.body)
    parsed['status'].should == 'success'

    UserSession.find.destroy
  end

  it "should get metadata history" do
    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    item = build(:sample)
    UserSession.create({ :login => @user.login, :password => @user.password })

    Metadata.stub(:find) {Metadata}
    Metadata.stub(:versions) {Metadata}
    Metadata.should_receive(:reject).and_return []


    get :get_metadata_history, { :id => '2', :offset => '5' }

    response.should be_success

    UserSession.find.destroy
  end

end
