class UserSession < Authlogic::Session::Base
  logout_on_timeout true
  # attr_accessible :session_id, :data
end
