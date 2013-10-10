require 'spec_helper'

describe Manager::ManagerController do
  render_views
  
  before do
  	@page_mock = create(:index)
    @template_mock = create(:sample)
    @testpl_mock = create(:testpl)
    @anotherpl_mock = create(:anotherpl)
    @even_pl_mock = create(:even)
    @odd_pl_mock = create(:odd)
    @rscript_rb_mock = create(:rscript)
    @meta_mock = create(:smeta)
    @js_mock = create(:sjs)
    @css_mock = create(:scss)
    @app_mock = create(:sapp)
    @index_sample_mock = create(:index_sample)
    @sample_meta_mock = create(:sample_meta)
    @sample_js_mock = create(:sample_js)
    @sample_css_mock = create(:sample_css) 
    @testpl_podio_mock = create(:testpl_podio)
    @anotherpl_podio_mock = create(:anotherpl_podio)
    activate_authlogic
    @user = create(:validUser)
    @adminRole = create(:adminRole)
    @userHasValidRole = create(:userHasValidRole)
  end
  
  after do
  	@page_mock.destroy
    @template_mock.destroy
    @testpl_mock.destroy
    @anotherpl_mock.destroy
    @even_pl_mock.destroy
    @odd_pl_mock.destroy
    @rscript_rb_mock.destroy
    @meta_mock.destroy
    @js_mock.destroy
    @css_mock.destroy
    @app_mock.destroy
    @user.destroy
    @adminRole.destroy
  end

  describe 'GET #login' do
    it "should return the login page" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy
      get :login

      response.should be_success
      response.body.should_not be_empty
    end

    it "should redirect if user is logged in" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      get :login
      response.code.should == '302'

      UserSession.find.destroy
    end
  end

  describe 'GET #select_application' do
    it "should return site selection page" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      controller.stub(:site_access).and_return true
      controller.stub(:get_current_user_role).and_return 'admin'

      get :select_application

      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end
  end

  describe 'GET #pages' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)
      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return the pages page" do
      @devUser = create(:validDevUser)

      UserSession.create({ :login => @devUser.login, :password => @devUser.password })
      Role.should_receive(:find).and_return RoleStruct.new('developer')

      get :pages
      
      response.should be_success
      response.body.should_not be_empty

      UserSession.find.destroy
      @devUser.destroy
    end

    it "should not return the pages if user is not logged in" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :pages }.to raise_error
    end
  end

  describe 'GET #elements' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:ensure_login).and_return true
      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return the elements page" do
      @devUser = create(:validDevUser)

      UserSession.create({ :login => @devUser.login, :password => @devUser.password })
      Role.should_receive(:find).and_return RoleStruct.new('developer')

      @curWksp = create(:currentworkspace)
      session[:accessible_app] = '123456'

      get :elements
      
      response.should be_success
      response.body.should_not be_empty

      @curWksp.destroy
      UserSession.find.destroy
    end

    it "should not return the elements page if user is not logged in" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :elements }.to raise_error
    end
  end

  describe 'GET #contentlib' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return the content library page" do
      @devUser = create(:validDevUser)

      UserSession.create({ :login => @devUser.login, :password => @devUser.password })
      Role.should_receive(:find).and_return RoleStruct.new('developer')

      get :contentlib

      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
      @devUser.destroy
    end

    it 'should not return the content library page if user is not logged in' do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :contentlib }.to raise_error
    end
  end

  describe 'GET #configure' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return the configuration page" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      get :configure
      
      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end

    it 'should not return the configuration page if user is not logged in' do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :configure }.to raise_error
    end
  end

  describe 'GET #file_manager' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return the file manager page" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      get :file_manager
      
      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end

    it 'should not return the file manage page if user is not logged in' do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :file_manager }.to raise_error
    end
  end

  describe 'GET #system' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:ensure_login).and_return true
      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return the system page" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      get :system
      
      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end

    it 'should not return the system page if user is not logged in' do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :system }.to raise_error
    end
  end

  describe 'GET #sites' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return the site page" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      get :sites

      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end
  end

  describe 'GET #extensions' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return extensions page" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      get :extensions

      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end

    it 'should not return extensions page if user is not logged in' do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :extensions }.to raise_error
    end
  end

  describe 'GET #users' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1

      RoleStruct = Struct.new(:name)

      controller.stub(:site_access).and_return true
    end

    after do

    end

    it "should return users page" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      get :users

      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end

    it "should not return users page if user is not logged in" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :users }.to raise_error
    end
  end

  describe 'GET #user_profile' do
    before do
      session[:accessible_roleid] = 1
      session[:accessible_appid] = 1
      session[:accessible_username] = 'admin'

      RoleStruct = Struct.new(:name)

      controller.stub(:site_access)
    end

    after do

    end

    it "should return user_profile page" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      SiteUserStruct = Struct.new(:is_owner)

      SiteUser.should_receive(:first).and_return SiteUserStruct.new(true)

      get :user_profile

      response.should be_success
      response.body.should_not be_empty
      UserSession.find.destroy
    end

    it "should not return user_profile page if user is not logged in" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      expect { get :user_profile }.to raise_error
    end
  end

  describe "GET #register" do
    before do
      session[:accessible_appid] = nil
      session[:accessible_roleid] = nil
    end

    after do

    end

    it "should return register page" do
      UserSession.create({ :login => @user.login, :password => @user.password })
      UserSession.find.destroy

      InvitationStruct = Struct.new(:id, :email, :accepted, :sites_id, :roles_id)

      Invitation.should_receive(:first).and_return InvitationStruct.new(1, 'test@test.com', false, 1, 1)
      User.should_receive(:find_by_email).and_return @user
      Invitation.should_receive(:find_all_by_email).and_return [InvitationStruct.new(1, 'test@test.com', false, 1, 1)]
      SiteUser.should_receive(:create).and_return true
      Invitation.should_receive(:update).and_return true

      get :register, { :invitation_id => '123456' }

      response.should redirect_to('/manager/cms')
    end
  end

end
