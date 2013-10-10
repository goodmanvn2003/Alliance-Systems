class RoleUser < ActiveRecord::Base
  attr_accessible :user_id, :role_id
end
