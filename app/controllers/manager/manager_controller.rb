class Manager::ManagerController < ApplicationController
  include ApplicationHelper, Manager::ManagerHelper

  layout 'manager'

  before_filter :get_current_user_role

  before_filter :site_access, :except => [
      :login,
      :register,
      :select_application
  ]

  before_filter :isEnabledOfs?, :except => [
      :login,
      :register,
      :select_application
  ]

  # Show login page
  def login
    if (@curUserRole == 'user')
      raise 'unauthorized access'
    elsif (@curUserRole == 'admin' ||
        @curUserRole == 'developer' ||
        @curUserRole == 'contentadmin' ||
        @curUserRole == 'loggedin')
      if (session[:accessible_app].nil?)
        redirect_to '/manager/cms/apps'
      else
        if (@curUserRole == 'contentadmin')
          redirect_to '/manager/cms/contentlib'
        elsif (@curUserRole == 'admin')
          redirect_to '/manager/cms/configure'
        else
          redirect_to '/manager/cms/pages'
        end
      end
      return
    end

    respond_to do |t|
      t.html { render :layout => 'authentication' }
    end
  end

  # Show register page for invitation
  def register
    if (@curUserRole != 'anonymous')
      raise 'unauthorized access'
    end

    # Check if user is existing for the current invitation, if it is, assign system user to workspace
    invitation = Invitation.first({ :conditions => ['invitation_id = ? and accepted = ?', params[:invitation_id], false] })

    if (invitation.nil?)
      raise "[Err] invitation doesn't exist"
    else
      invitedUser = User.find_by_email(invitation.email)
      invitationsByEmail = Invitation.find_all_by_email(invitation.email)
      foundInvitationByEmail = false

      invitationsByEmail.each do |t|
        if (t.accepted == true and t.invitation_id == params[:invitation_id] )
          foundInvitationByEmail = true
          break
        end
      end

      if (foundInvitationByEmail)
        raise "[Err] invitation was claimed"
      else
        if (invitedUser.nil?)
          respond_to do |t|
            t.html { render :layout => 'authentication' }
          end
        else
          SiteUser.create({
                              :sites_id => invitation.sites_id,
                              :users_id => invitedUser.id,
                              :is_owner => false,
                              :roles_id => invitation.roles_id
                          })
          Invitation.update(invitation.id, { :accepted => true })

          if (!UserSession.find.nil?)
            UserSession.find.destroy
          end
          reset_session

          redirect_to '/manager/cms'
        end
      end

    end
  end

  # Select application on login
  def select_application
    if (@curUserRole == 'user' ||
        @curUserRole == 'anonymous')
      raise 'unauthorized access'
    end

    @userSites = get_users_applications

    respond_to do |t|
      t.html { render :layout => 'authentication'}
    end
  end

  # Show view called "pages" and its view variables
  def pages

    if (@curUserRole == 'admin' ||
        @curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = request.original_url

    @mPage = 'home'

    @listOfTemplates = Metadata.all({:conditions => ['cat = ? and sites_id = ?', 'template', session[:accessible_appid]]})
    @pages = Metadata.all({:conditions => ['cat = ? and sites_id = ? and flags = ?', 'page', session[:accessible_appid], 0]})

    @mountedExts = SystemModel.get_list_of_compatible_gems
    respond_to do |t|
      t.html
    end
  end

  # Show view called "elements" and its view variables
  def elements

    if (@curUserRole == 'admin' ||
        @curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = request.original_url

    @mPage = 'elements'

    metadata = Metadata.all({ :conditions => ['sites_id = ? and flags = ?', session[:accessible_appid], 0]})
    tPagesArray = Array.new

    metadata.each do |t|
      tHash = Hash.new
      tPageItem = t.cat.to_s.strip

      if (tPageItem == 'template')
        tHash['id'] = t.id.to_s.strip
        tHash['key'] = t.key.to_s.strip
        tPagesArray << tHash
      end
    end

    @pages = tPagesArray

    tLayoutsArray = Array.new

    metadata.each do |t|
      tHash = Hash.new
      tLayoutItem = t.cat.to_s.strip

      if (tLayoutItem == 'placeholder')
        tHash['id'] = t.id.to_s.strip
        tHash['key'] = t.key.to_s.strip
        tLayoutsArray << tHash
      end
    end

    @layouts = tLayoutsArray

    # Get a list of files for styles
    @css = Metadata.all({:conditions => ['cat = ? and sites_id = ? and flags = ?', 'css', session[:accessible_appid], 0]})
    # Get all javascripts
    @js = Metadata.all({:conditions => ['cat = ? and sites_id = ? and flags = ?', 'js', session[:accessible_appid], 0]})
    # Get all meta tags informations
    @metas = Metadata.all({:conditions => ['cat = ? and sites_id = ? and flags = ?', 'meta', session[:accessible_appid], 0]})

    @mountedExts = SystemModel.get_list_of_compatible_gems

    # Get all scripts
    @rubies = Metadata.all({:conditions => ['cat = ? and sites_id = ? and flags = ?', 'ruby', session[:accessible_appid], 0]})

    respond_to do |t|
      t.html
    end
  end

  # Show view called "configure" and its view variables
  def configure
    if (@curUserRole == 'developer' ||
        @curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = request.original_url

    @mPage = 'configure'
    @metadatas = Metadata.all({:conditions => ['sites_id = ?', session[:accessible_appid]]})

    cookies[:url] = "/manager/configure"

    @mountedExts = SystemModel.get_list_of_compatible_gems

    respond_to do |t|
      t.html
    end
  end

  # Show view called "file_manager" and its view variables
  def file_manager
    if (@curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = request.original_url

    @mPage = 'file_manager'

    @mountedExts = SystemModel.get_list_of_compatible_gems

    respond_to do |t|
      t.html
    end
  end

  # Show view called "contentlib" and its view variables
  def contentlib
    if (@curUserRole == 'admin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous'||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = request.original_url

    @mPage = 'contentlib'

    @mountedExts = SystemModel.get_list_of_compatible_gems
  end

  # Show view called "system" and its view variables
  def system
    if (@curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = request.original_url

    constServiceAccountInfoKey = "serviceAccountName"
    @mPage = 'system'

    # List of restricted system items
    @systemRestricteds = %w(serviceAccountName serviceAccountPass currentWorkspace)

    @mountedExts = SystemModel.get_list_of_compatible_gems

    respond_to do |t|
      t.html
    end
  end

  # Show view called "users" and its view variables
  def users
    if (@curUserRole == 'developer' ||
        @curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = request.original_url

    @GROUP_NAME_FILTERABLES = {
        'admin' => 'Administrator',
        'developer' => 'Developer',
        'contentadmin' => 'Content Manager',
        'user' => 'User',
        'anonymous' => 'Anonymous'
    }

    tRoles = Array.new
    allRoles = Role.all
    allRoles.each do |f|
      tRoles << ((@GROUP_NAME_FILTERABLES.map { |k,v| k.strip == f.name.strip ? Hash['id', f.id, 'name', v.strip] : '' }).select { |t| !t.empty? })[0]
    end
    @roles = tRoles.reject { |t| t['name'] == 'User' }

    @mPage = 'users'

    @mountedExts = SystemModel.get_list_of_compatible_gems

    respond_to do |t|
      t.html
    end
  end

  # Show view called "user_profile" and its view variables
  def user_profile
    if (@curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    user = User.find_by_login(session[:accessible_username])
    @username = user.login.strip
    @email = user.email.strip

    @mPage = 'user_profile'

    @mountedExts = SystemModel.get_list_of_compatible_gems

    ##
    siteUser = SiteUser.first({ :conditions => ['sites_id = ? and users_id = ?', session[:accessible_appid], user.id ]})
    tRoles = Array.new

    if (siteUser.is_owner)
      tRoles = Role.all.reject { |t| t.name == 'admin' }
    else
      tRoles = Role.all
    end

    @roles = tRoles.reject { |t| t.name == 'user' }
    ##

    respond_to do |t|
      t.html
    end
  end

  # Show view called "extensions" and its view variables
  def extensions

    if (@curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"

    extId = params[:id]
    @mPage = 'extensions'
    @mExt = extId

    @mountedExts = SystemModel.get_list_of_compatible_gems

    respond_to do |t|
      t.html
    end

  end

  # Show view called "sites" and its view variables
  def sites

    if (@curUserRole == 'developer' ||
        @curUserRole == 'contentadmin' ||
        @curUserRole == 'user' ||
        @curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    cookies[:url] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"

    @mPage = 'apps'
    @userSites = get_users_applications
    @userSitesCategories = Metadata.select('distinct key').where({ :cat => 'site'})

    @mountedExts = SystemModel.get_list_of_compatible_gems

    respond_to do |t|
      t.html
    end

  end

  # Show view called "archives" and its view variables
  def archives

    if (@curUserRole == 'anonymous' ||
        @curUserRole == 'loggedin')
      raise 'unauthorized access'
    end

    @mPage = "archives"

    @mountedExts = SystemModel.get_list_of_compatible_gems

    respond_to do |t|
      t.html
    end

  end

  private

end