class Site < ActiveRecord::Base
  attr_accessible :sites_id

  has_many :site_users, :dependent => :destroy, :foreign_key => 'sites_id'
  has_many :metadatas, :dependent => :destroy, :foreign_key => 'sites_id'
  has_many :invitations, :dependent => :destroy, :foreign_key => 'sites_id'
end
