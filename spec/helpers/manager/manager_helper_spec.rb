require 'spec_helper'

describe Manager::ManagerHelper do
  before do
    @dataUser = create(:validUser)
    activate_authlogic
  end

  after do
    @dataUser.destroy
  end

  it 'should check site access' do
    session[:accessible_app] = 'myapp'
    session[:accessible_roleid] = '1'

    helper.site_access.should be_nil
  end

  it 'should get users applications' do
    user = build(:validUser)

    UserSession.create({ :login => user.login, :password => user.password })
    SiteStruct = Struct.new(:value, :sites_id)
    SiteUserStruct = Struct.new(:id)

    SiteUser.stub(:find_all_by_users_id) { SiteUser }
    SiteUser.stub(:map) { SiteUser }
    SiteUser.should_receive(:uniq).and_return [SiteUserStruct.new(1)]
    Metadata.should_receive(:find_by_sites_id).at_least(:once).and_return SiteStruct.new('{ "name" : "1" }', 1)

    helper.get_users_applications.should_not be_nil
    UserSession.find.destroy
  end
end