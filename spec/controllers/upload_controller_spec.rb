require 'spec_helper'

describe UploadController do

	before do
		controller.stub(:ensure_login).and_return true
		@uploadables = ["/resources/rspec.png",
						"/resources/text.js",
						"/resources/text.css",
						"/resources/_test.css"
						]
		@img_file = fixture_file_upload("/files/rspec.png","image/png", :binary)
		@text_js_file = fixture_file_upload("/files/text.js","text/javascript")
		@text_css_file = fixture_file_upload("/files/text.css","text/javascript")
		@unkown_ext_file = fixture_file_upload("/files/text.pdf","application/pdf")
		@valid_text_filename = "/resources/styles.css"
		@invalid_text_filename = "/resources/style_invalid.css"
		@test_filename = "/resources/_test.css"
		@test_fileid = "test"
		@test_filecontent = "body {}"
		@test_filemeta = Metadata.create({
			:key => @test_fileid,
			:cat => "css",
			:value => @test_filename
		})
    @user = create(:validUser)
    @adminRole = create(:adminRole)
    @userHasValidRole = create(:userHasValidRole)
    activate_authlogic
  end

  after do
    @user.destroy
    @adminRole.destroy
  end

	it "should upload image file from client to server" do
    UserSession.create({ :login => @user.login, :password => @user.password })

		category = "png"

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    # DataFile.should_receive(:save).and_return true
    File.should_receive(:open).and_return true

    post :uploadFile, :fileUpload => { :datafile => @img_file }, :fileCategory => category, :filePath => "/imgs"
		
		response.should be_success
		json = JSON.parse(response.body)
		expect(json['status']).to eq("success")

    UserSession.find.destroy
	end
	
	it "should upload js file from client to server" do
    UserSession.create({ :login => @user.login, :password => @user.password })

		category = "js"

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    # DataFile.should_receive(:save).and_return true
    File.should_receive(:open).and_return true
    Metadata.should_receive(:first).and_return false

    post :uploadFile, :fileUpload => { :datafile => @text_js_file }, :fileCategory => category, :filePath => "/js"
		
		response.should be_success
		json = JSON.parse(response.body)
		expect(json['status']).to eq("success")

    UserSession.find.destroy
	end
	
	it "should upload css file from client to server" do
    UserSession.create({ :login => @user.login, :password => @user.password })

		category = "css"

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    File.should_receive(:open).and_return true
    Metadata.should_receive(:first).and_return false

    # DataFile.should_receive(:save).and_return true
		post :uploadFile, :fileUpload => { :datafile => @text_css_file }, :fileCategory => category, :filePath => "/css" 
		
		response.should be_success
		json = JSON.parse(response.body)
		expect(json['status']).to eq("success")
		
		# File.delete("#{Rails.root}/public#{@uploadables[2]}")

    UserSession.find.destroy
	end
	
	it "should not upload file with invalid extension" do
    UserSession.create({ :login => @user.login, :password => @user.password })

		category = "undefined" 
		post :uploadFile, :fileUpload => { :datafile => @unkown_ext_file }, :fileCategory => category, :filePath => "/public/resources/js"
		
		response.should be_success
		json = JSON.parse(response.body)
		expect(json['status']).to eq("failure")

    UserSession.find.destroy
	end

	it "should get file content from server when file is existing" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    File.should_receive(:exists?).and_return true
    File.stub(:open) { File }
    File.should_receive(:each).and_return ['']

		get :getFile, :file => @valid_text_filename
		
		response.should be_success
		expect(response.body).not_to eq("failure")

    UserSession.find.destroy
	end
	
	it "should not get file content from server when file is not existing" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

    File.should_receive(:exists?).at_least(:once).and_return false

		get :getFile, :file => @invalid_text_filename
		
		response.should_not be_success

    UserSession.find.destroy
	end

	it "should update existing file on server" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

		# File.open("#{Rails.root}/public/resources/css/_test.css", "w+") { |t| t.write(@test_filecontent) }
    File.should_receive(:exists?).at_least(:once).and_return true
    File.should_receive(:open).at_least(:once).and_return true
		get :saveTextFile, :file => @test_filename, :fileContent => @test_filecontent
		
		response.should be_success
		expect(response.body).to eq("success")

    UserSession.find.destroy
	end
	
	it "should not update invalid file which is not on server" do
    UserSession.create({ :login => @user.login, :password => @user.password })

		get :saveTextFile, :file => @invalid_text_filename, :fileContent => @test_filecontent
		
		response.should be_success
		expect(response.body).to eq("failure")

    UserSession.find.destroy
	end
	
	it "should delete registered file on server" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

		File.should_receive(:exists?).and_return true
    File.should_receive(:delete).and_return true
    Metadata.should_receive(:where).and_return nil
		post :deleteFile, :file => @test_filename, :fileCat => "css", :fileId => @test_fileid
		
		response.should be_success
		expect(response.body).to eq("success")

    UserSession.find.destroy
	end
	
	it "should delete non-registered file on server" do
    UserSession.create({ :login => @user.login, :password => @user.password })

    RoleStruct = Struct.new(:name)
    SiteUserStruct = Struct.new(:roles_id)

    session[:accessible_appid] = 1
    session[:accessible_roleid] = 1

    Role.should_receive(:find).at_least(:once).and_return RoleStruct.new('admin')

		post :deleteFile, :file => @test_filename, :fileCat => "css", :fileId => @test_fileid
		
		response.should be_success
		expect(response.body).to eq("success")

    UserSession.find.destroy
	end
	
end
