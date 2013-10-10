class User < ActiveRecord::Base
  attr_accessible :password, :password_confirmation, :login, :email, :password_salt, :persistence_token, :perishable_token

  validates_uniqueness_of :email
  validates_format_of :login, :with => /^[^ \W]+$/
  validates_format_of :password, :with => /^[^ \W\_]+$/
  validates_format_of :password_confirmation, :with => /^[^ \W\_]+$/

  has_many :site_users, :dependent => :destroy, :foreign_key => 'users_id'
  has_many :releases, :dependent => :destroy, :foreign_key => 'users_id'

  acts_as_authentic do |c|
    c.login_field = 'login'
    c.logged_in_timeout = 24.hours
  end

  def activate!
    begin
      self.update_attribute(:active, true)
    rescue Exception => ex
      logger.debug(ex.message)
    end
  end
end
