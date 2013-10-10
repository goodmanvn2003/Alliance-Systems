class Invitation < ActiveRecord::Base
  attr_accessible :invitation_id, :email, :roles_id, :sites_id, :accepted

  belongs_to :role
  belongs_to :site
end
