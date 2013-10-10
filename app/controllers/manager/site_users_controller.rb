class Manager::SiteUsersController < ApplicationController
  include ApplicationHelper

  layout nil

  before_filter :is_current_accessible?

  # POST site_user
  def create
    begin
      # Find the registered user
      user = User.find(params[:user])

      # Find the registered user's role
      user_role = Role.find(params[:role])

      # Find the current site
      site = nil
      if (!session[:accessible_appid].nil?)
        site = Site.find(session[:accessible_appid])
      else
        raise 'site was not found or empty'
      end

      # Associate that user with current site
      SiteUser.create({
        :sites_id => site.id,
        :users_id => user.id,
        :is_owner => false,
        :roles_id => user_role.id
      })

      render :json => { :status => 'success' }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # PUT site_user(:id = 1)
  def update
    render :json => { :status => 'nothing' }
  end

  # DELETE site_user(:id = 1)
  def destroy
    begin
      siteUser = SiteUser.first({ :conditions =>  ['sites_id = ? and users_id = ? and roles_id = ?', session[:accessible_appid], params[:id], params[:groupId] ]})
      if (!siteUser.nil?)
        siteUser.destroy
        render :json => { :status => 'success' }
      else
        render :json => { :status => 'failure', :message => "user doesn't exist" }
      end
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  private

end