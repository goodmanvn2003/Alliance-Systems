class UserSessionsController < ApplicationController
  include UserSessionsHelper

  def authenticate
    if (@called.include?('manager'))
      if (User.count == 0)
        if (!params[:login].empty? && !params[:password].empty? && !params[:newApp].empty?)
          create_default_user_with_app(params[:login], params[:password], params[:password_confirmation], params[:email], params[:newApp], params[:newAppDesc])
        else
          flash[:err] = 'Either account name, password, application or other fields is missing'
          flash[:login] = params[:login]
          redirect_to '/manager/cms'
        end
      else
        if (!params[:login].empty? && !params[:password].empty?)

          @session = UserSession.new(:login => params[:login], :password => params[:password])
          if (@session.save)
            session[:accessible_username] = params[:login].strip
            session[:accessible_userid] = UserSession.find.record.id
            redirect_to '/manager/cms/apps'
          else
            flash[:err] = 'Either account name or passwords is incorrect'
            flash[:login] = params[:login]
            redirect_to '/manager/cms'
          end

        else
          flash[:warn] = 'Either account name or passwords is missing'
          flash[:login] = params[:login]
          redirect_to '/manager/cms'
        end
      end
    else
      raise 'unauthorized access'
    end
  end

  def client_authenticate
    if (!@called.include?('manager'))
      if (!params[:login].empty? && !params[:password].empty?)
        @session = UserSession.new(:login => params[:login], :password => params[:password])
        if (@session.save)
          redirect_to request.referrer
        else
          flash[:msg] = 'Either account name or passwords is incorrect'
          redirect_to request.referrer
        end
      else
        flash[:msg] = 'Either account name or passwords is missing'
        redirect_to request.referrer
      end
    else
      raise 'unauthorized access'
    end
  end

  def create_user_with_invitation
    data = {
        :login => params[:login],
        :password => params[:password],
        :password_confirmation => params[:password_confirmation],
        :email => params[:email]
    }

    if (!data[:email].nil? && !data[:email].empty?)
      user = User.new(data)
      user.active = true
      activeInvitation = Invitation.first({:conditions => ['invitation_id = ? and email = ?', params[:invitation_id], data[:email]]})

      if (!activeInvitation.nil?)
        if (user.save)
          SiteUser.create({
                              :sites_id => activeInvitation.sites_id,
                              :users_id => user.id,
                              :is_owner => false,
                              :roles_id => activeInvitation.roles_id
                          })

          # Update invitation status
          Invitation.update(activeInvitation.id, {:accepted => true})

          # Reset session
          if (!UserSession.find.nil?)
            UserSession.find.destroy
          end
          reset_session

          redirect_to '/manager/cms'
        else
          errors = ''
          user.errors.full_messages.each do |e|
            errors << "#{e}<br />"
          end

          flash[:err] = errors
          redirect_to request.referrer
        end
      else
        flash[:err] = "Invitation doesn't exist for email \"#{data[:email].strip}\""
        redirect_to request.referrer
      end
    else
      flash[:err] = "Email is required so that your invitation can be validated"
      redirect_to request.referrer
    end

  end

  # Set active application/site for user to manage
  def set_active_application
    userAppId = params[:appSelect]
    userRoleId = params[:roleSelect]

    if (userAppId.nil? || userAppId.empty?)
      flash[:err] = 'No site was selected'

      redirect_to '/manager/cms/apps'
      return
    end
    if (userRoleId.nil? || userRoleId.empty?)
      flash[:err] = 'No role was selected'

      redirect_to '/manager/cms/apps'
      return
    end

    userApp = Site.find(userAppId).sites_id
    session[:accessible_app] = userApp
    session[:accessible_appid] = userAppId
    session[:accessible_roleid] = userRoleId

    # Get site name
    userAppInfo = Metadata.first({:conditions => ['sites_id = ? and key = ?', userAppId, 'preferences']})
    if (userAppInfo.nil?)
      session[:accessible_appname] = nil
    else
      session[:accessible_appname] = ActiveSupport::JSON.decode(userAppInfo.value)['name'].strip
    end

    redirect_to "/manager/cms"

  end

  def logout
    @session = UserSession.find
    @session.destroy
    reset_session

    if (!@called.nil?)
      if (@called.include?('manager'))
        flash[:msg] = 'You have just been logged out successfully'
        redirect_to '/manager/cms'
      else
        redirect_to request.referrer
      end
    else
      redirect_to '/manager/cms'
    end
  end

  private

end