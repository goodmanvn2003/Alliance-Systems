class Manager::UsersController < ApplicationController
  include ApplicationHelper

  layout nil

  # Only allow access of 'admin'
  # Deny access of 'developer', 'content admin', 'user' and 'anonymous'

  before_filter :is_current_accessible?, :except => [
      :create_user_only,
      :activate_user
  ]

  # POST user
  def create
    begin
      user = User.new(params[:newUser])
      if (user.save!)

        userRole = Role.find(params[:newRole])

        # After user is created, add the user to site
        app = session[:accessible_appid]
        SiteUser.create({
                        :users_id => user.id,
                        :sites_id => app,
                        :is_owner => false,
                        :roles_id => userRole.id
                        })
        # Send an activation email to user
        UserMailer.activate_account_email(user, "#{request.host_with_port}/manager/users/activate/#{Digest::SHA256.hexdigest(user.id.to_s)}").deliver

        # Henceforth, everything should be successfully completed
        render :json => { :status => 'success' }
      else
        render :json => { :status => 'failure', :message => 'Validation failed' }
      end
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  def create_user_only
    begin
      user = User.new(params[:newUser])
      if (user.save!)
        # Send an activation email to user
        UserMailer.activate_account_email(user, "#{request.host_with_port}/manager/users/activate/#{Digest::SHA256.hexdigest(user.id.to_s)}").deliver
        render :json => { :status => 'success' }
      else
        render :json => { :status => 'failure', :message => 'Validation failed' }
      end
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  def activate_user
    begin
      users = User.all
      found = nil

      users.each do |t|
        idHash = Digest::SHA256.hexdigest(t.id.to_s)
        if (idHash == params[:code])
          found = t
          break
        end
      end

      if (!found.nil?)
        if (!found.active?)
          found.activate!
          flash[:success] = "Account has just been successfully activated"
        else
          flash[:warn] = "Account has already been activated"
        end

        redirect_to("/manager/cms")
      else
        raise "[Err] activation code was not found"
      end
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # PUT user(:id => 1)
  def update
    begin
      # if old password is empty, just modify email infos
      # if old password is NOT empty, modify everything
      if (params[:oldPassword].empty?)

        user = User.find_by_id(params[:id])

        if (!user.nil?)
          if (/(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$)/ === params[:user]['email'])
            user.update_attribute(:email, params[:user]['email'])
            render :json => { :status => 'success' }
          else
            render :json => { :status => 'failure', :message => 'Validation failed: email is invalid' }
          end
        else
          render :json => { :status => 'failure', :message => 'user doesn\'t exist' }
        end
      else
        user = User.find_by_id(params[:id])
        if (!user.nil?)
          if (user.valid_password?(params[:oldPassword], true))
            user.update_attributes!(params[:user])
            render :json => { :status => 'success' }
          else
            render :json => { :status => 'failure', :message => 'password is invalid' }
          end
        else
          render :json => { :status => 'failure', :message => 'user doesn\'t exist' }
        end
      end

    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  def update_self
    begin
      user = User.find(session[:accessible_userid])
      updated = user.update_attribute(:email, params[:data]['email'])

      render :json => { :status => 'success' }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # PUT users/role(:id => 1)
  def update_role
    begin

      # Find site user
      siteUser = SiteUser.first({ :conditions => ['users_id = ? and roles_id = ? and sites_id = ?', params[:id], params[:role], session[:accessible_appid]]})

      if (!siteUser.nil?)
        render :json => { :status => 'failure', :message => 'role has already been assigned to user' }
      else
        # Check if role exists
        siteUser = SiteUser.first({ :conditions => ['users_id = ? and roles_id = ? and sites_id = ?', params[:id], params[:roleOrig], session[:accessible_appid]]})
        role = Role.find(params[:role])
        if (!role.nil?)
          if (siteUser.is_owner == false)
            SiteUser.update(siteUser.id, {:roles_id => role.id})
            render :json => { :status => 'success' }
          else
            render :json => { :status => 'failure', :message => 'owner cannot be delegated' }
          end
        else
          render :json => { :status => 'failure', :message => 'role is not found' }
        end
      end

    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # DELETE user(:id => 1)
  def destroy
    begin
      User.destroy(params[:id])

      render :json => { :status => "success" }
    rescue Exception => ex
      render :json => { :status => "failure", :message => ex.message }
    end
  end

  private

end