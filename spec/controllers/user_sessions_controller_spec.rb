require 'spec_helper'

describe UserSessionsController do

  describe "POST #create_user" do

    before :all do
      @user = build(:validUser)
      TLogin_User = Struct.new(:login,:password,:password_confirmation,:email)
    end

    subject { post :authenticate, {:login => @user.login, :password => @user.password, :password_confirmation => @user.password_confirmation, :email => @user.email, :newApp => '123456'} }

    it 'should create default account if user table is empty' do
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/manager/cms'
      role = create(:adminRole)
      Dir.should_receive(:mkdir).at_least(0).and_return true
      UserMailer.stub(:activate_account_email) { UserMailer }
      UserMailer.should_receive(:deliver).and_return true

      expect(subject).to redirect_to('/manager/cms')

      role.destroy
    end

    it 'should not create default account if user is invalid' do
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/manager/cms'
      @user = build(:invalidUserShortPassword)
      expect(subject).to redirect_to('/manager/cms')
    end

    it 'should not create defaut account if user credential infos are missing' do
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/manager/cms'

      @user = TLogin_User.new('admin','','','someemail@gmail.com')
      expect(subject).to redirect_to('/manager/cms')
    end
  end

  describe "POST #login" do
    before :all do
      @user = create(:validUser)
      @role = create(:adminRole)
      @userHasRole = create(:userHasValidRole)
      @login_user = build(:validUser)
    end

    after :all do
      @user.destroy
      @role.destroy
    end

    subject { post :authenticate, {:login => @login_user.login, :password => @login_user.password } }

    it 'should log in if user table is not empty and the login credential is valid' do
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/manager/cms'
      expect(subject).to redirect_to('/manager/cms/apps')
    end

    it 'should not login if login credential is invalid' do
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/manager/cms'
      @login_user = build(:invalidUser)
      expect(subject).to redirect_to('/manager/cms')
    end

    it 'should not login if login password is missing' do
      TLogin_User_Two = Struct.new(:login,:password)
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/manager/cms'

      @login_user = TLogin_User_Two.new('admin','')
      expect(subject).to redirect_to('/manager/cms')
    end

    it 'should deny access if user is not using manager for logging in' do
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/index'

      expect { post :authenticate, {:login => @login_user.login, :password => @login_user.password } }.to raise_error
    end
  end

  describe "POST #client_login" do
    before :all do
      @user = create(:validUser)
      @login_user = build(:validUser)
    end

    after :all do
      @user.destroy
    end

    subject { post :client_authenticate, {:login => @login_user.login, :password => @login_user.password } }

    it 'should log in if user infos are valid' do
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://localhost:3000/index'

      expect(subject).to redirect_to(controller.request.referrer)
    end

    it 'should not log in if user infos are invalid' do
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://localhost:3000/index'

      @login_user = build(:invalidUser)
      expect(subject).to redirect_to(controller.request.referrer)
    end

    it 'should not log in if user infos are missing' do
      TLogin_User_Two = Struct.new(:login,:password, :email)
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://localhost:3000/index'

      @login_user = TLogin_User_Two.new('admin','','email@email.com')
      expect(subject).to redirect_to(controller.request.referrer)
    end

    it 'should deny access if user tries to access from manager' do
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://localhost:3000/manager/cms'

      expect { post :client_authenticate, {:login => @login_user.login, :password => @login_user.password } }.to raise_error
    end
  end

  describe "POST #set_active_application" do
    before do
      @user = create(:validUser)
      activate_authlogic
    end

    after do
      @user.destroy
    end

    subject { post :set_active_application, { :appSelect => 1, :roleSelect => 1 } }

    it "should set active application" do
      UserSession.create({ :login => @user.login, :password => @user.password })

      TMetadata = Struct.new(:value)
      TSite = Struct.new(:sites_id)

      Site.should_receive(:find).and_return TSite.new(1)
      Metadata.should_receive(:first).and_return TMetadata.new('{"name":"pairs"}')
      ActiveSupport::JSON.should_receive(:decode).and_return 'a name'

      expect(subject).to redirect_to("/manager/cms")
    end

  end

  describe "GET #logout" do
    before do
      @user = create(:validUser)
      activate_authlogic
    end

    after do
      @user.destroy
    end

    subject { get :logout }

    it 'should log out successfully in manager' do
      UserSession.create({ :login => @user.login, :password => @user.password })
      controller.request.should_receive(:referrer).and_return 'http://localhost:3000/manager/cms'

      expect(subject).to redirect_to('/manager/cms')
    end

    it 'should log out successfully elsewhere' do
      UserSession.create({ :login => @user.login, :password => @user.password })
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://localhost:3000/index'

      expect(subject).to redirect_to(controller.request.referrer)
    end
  end

  describe "POST #create_user_with_invitation" do
    before do
      UserStruct = Struct.new(:login, :password, :password_confirmation, :email)
      TInvitation = Struct.new(:id, :sites_id, :roles_id, :email)
      @newbie = UserStruct.new('newuser','123456', '123456', 'test@test.com')
      @invalidNewbie = UserStruct.new('newuser?#','654321','123456','test@com')
      @invitation = TInvitation.new(1, 1, 1, 'test@test.com')
    end

    after do

    end

    subject { post :create_user_with_invitation, { :login => @newbie.login, :password => @newbie.password, :password_confirmation => @newbie.password_confirmation, :email => @newbie.email } }

    it "should create user with invitation" do
      Invitation.should_receive(:first).and_return @invitation
      SiteUser.should_receive(:create).and_return true
      Invitation.should_receive(:update).and_return true

      expect(subject).to redirect_to('/manager/cms')
    end

    it "should not allow user with invalid email to register" do
      Invitation.should_receive(:first).and_return nil
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://test.host/manager/cms'

      expect(subject).to redirect_to('/manager/cms')
    end

    it "should not process registration if user info is invalid" do
      Invitation.should_receive(:first).and_return @invitation
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://test.host/manager/cms'

      expect(post :create_user_with_invitation, { :login => @invalidNewbie.login, :password => @invalidNewbie.password, :password_confirmation => @invalidNewbie.password_confirmation, :email => @invalidNewbie.email }).to redirect_to('/manager/cms')
    end

    it "should not process if email params is missing" do
      controller.request.should_receive(:referrer).at_least(:once).and_return 'http://test.host/manager/cms'
      expect(post :create_user_with_invitation, { :login => @invalidNewbie.login, :password => @invalidNewbie.password, :password_confirmation => @invalidNewbie.password_confirmation, :email => nil }).to redirect_to('/manager/cms')
    end

  end

end