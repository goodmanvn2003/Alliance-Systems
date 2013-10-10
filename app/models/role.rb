class Role < ActiveRecord::Base
  attr_accessible :name, :authorizable_type, :authorizable_id

  has_many :site_users, :dependent => :destroy, :foreign_key => 'roles_id'
  has_many :invitation, :dependent => :destroy, :foreign_key => 'roles_id'

end
