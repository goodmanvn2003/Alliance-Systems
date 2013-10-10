class SiteUser < ActiveRecord::Base
  attr_accessible :sites_id, :users_id, :is_owner, :roles_id

  belongs_to :site
  belongs_to :user
  belongs_to :role
end
