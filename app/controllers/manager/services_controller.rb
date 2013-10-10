class Manager::ServicesController < ApplicationController
  include ApplicationHelper, Manager::ServicesHelper

  before_filter :ensure_local_login
  before_filter :get_current_user_role, :only => [
      :create_site,
      :delete_site,
      :get_site_information,
      :get_users_sites,
      :set_user_assigned_role,
      :get_list_users_by_group,
      :get_list_of_all_users_by_filter,
      :send_invitation_email_to_user,
      :get_metadata_history,
      :get_metadata_history_item,
      :get_metadata_archives
  ]

  # Will use prepare_one_by_id
  # Output json string
  def fetch_one_by_id

    if (@currentSession.nil?)
      render :json => {}
      return
    end

    app = session[:accessible_appid].to_s
    query = params[:id].strip
    result = prepare_one_by_id(app, query)
    render :json => result.nil? ? {} : result
  end

  # Will use prepare_one_by_key
  # Output json string
  def fetch_one_by_key

    if (@currentSession.nil?)
      render :json => {}
      return
    end

    app = session[:accessible_appid].to_s
    query = params[:key].strip
    cat = params[:cat].strip
    result = prepare_one_by_key(app, query, cat)
    render :json => result.nil? ? {} : result
  end

  def fetch_one_by_value

    if (@currentSession.nil?)
      render :json => {}
      return
    end

    app = session[:accessible_appid].to_s
    query = params[:value].strip
    cat = params[:cat].strip
    result = prepare_one_by_value(app, query, cat)
    render :json => result.nil? ? {} : result
  end

  # Activate Item for other items
  # Inputs from GET['item'] and GET['tpl']
  # Outputs json string
  # DONE Rename dataItem and dataTemplate to something else
  def set_active_item

    if (@currentSession.nil?)
      render :json => {:status => "failure", :message => "unauthorized"}
      return
    end

    destId = params[:destId]
    srcId = params[:srcId]

    # app association only
    type = params[:type]
    # experimental code
    if (type == "app_assoc")
      MetadataAssociation.destroy_all(:srcId => srcId.to_i)
    end

    dItem = MetadataAssociation.where("srcId = ? and destId = ?", srcId.to_i, destId.to_i).first

    if (!dItem.nil?)
      render :json => {:status => "success", :message => "found"}
    else
      metadataAssoc = MetadataAssociation.create({:srcId => srcId.to_i, :destId => destId.to_i})

      metadataAssoc.save!

      render :json => {:status => "success", :message => "nothing to do"}
    end
  end

  # Deactivate Item for other items
  # Inputs from GET['item'] and GET['tpl']
  # Outputs json string
  # DONE Rename dataItem and dataTemplate to something else
  def remove_active_item

    if (@currentSession.nil?)
      render :json => {:status => "failure", :message => "unauthorized"}
      return
    end

    destId = params[:destId]
    srcId = params[:srcId]

    dItem = MetadataAssociation.where("srcId = ? and destId = ?", srcId.to_i, destId.to_i).first

    if (!dItem.nil?)
      dItem.destroy
      render :json => {:status => "success", :message => "found"}
    else
      render :json => {:status => "success", :message => "nothing to do"}
    end
  end

  # Get items for template
  # Inputs from GET['tpl']
  # Outputs json string
  def get_items_of_template

    if (@currentSession.nil?)
      render :json => {:status => "failure", :message => "unauthorized"}
      return
    end

    data = params[:tpl]

    dItems = MetadataAssociation.where("srcId = ?", data)

    if (!dItems.nil? && !dItems.empty?)
      render :json => {:status => "success", :message => "found", :data => dItems}
    else
      render :json => {:status => "success", :message => "nothing to do"}
    end
  end

  # Get list of configuration items by cat
  # Input
  # Output
  def get_list_of_configuration_items_by_cat

    if (@currentSession.nil?)
      render :json => []
      return
    end

    begin
      cat = params[:cat]
      app = session[:accessible_appid].to_s
      configs = Metadata.all({:conditions => ['cat = ? and sites_id = ?', cat, app]})
      render :json => configs
    rescue
      render :json => []
    end
  end

  # Get list of configuration items by associations
  # Input
  # Output
  def get_list_of_configuration_items_by_assoc

    if (@currentSession.nil?)
      render :json => []
      return
    end

    begin
      item = params[:item]
      cat = params[:cat]
      app = session[:accessible_appid].to_s
      configs = Array.new

      # Find source item
      tItem = Metadata.find(item)

      # If the item doesn't exist, do nothing
      if (!tItem.nil?)
        # Find its associations
        tConfigs = defined?(tItem.MetadataAssociation) ? tItem.MetadataAssociation : []

        # Find all items of request category
        metadata = Metadata.all({:conditions => ['cat = ? and sites_id = ?', cat, app]})

        # Get content for each associated item
        tConfigs.each do |t|
          tItem = metadata.select { |obj| obj.id == t.destId }
          if (!tItem[0].nil?)
            configs << tItem[0]
          end
        end
      end

      render :json => configs
    rescue
      render :json => []
    end
  end

  # Get list of configuration items by associations in reverse
  # Input
  # Output
  def get_list_of_configuration_items_by_assoc_in_reverse

    if (@currentSession.nil?)
      render :json => []
      return
    end

    begin
      item = params[:item]
      cat = params[:cat]
      app = session[:accessible_appid].to_s
      configs = Array.new

      # Find source item
      tItem = Metadata.find(item)

      # If the item doesn't exist, do nothing
      if (!tItem.nil?)
        # Find its associations
        tConfigs = MetadataAssociation.find_all_by_destId(tItem)

        # Find all items of request category
        metadata = Metadata.all({:conditions => ['cat = ? and sites_id = ?', cat, app]})

        # Get content for each associated item
        tConfigs.each do |t|
          tItem = metadata.select { |obj| obj.id == t.srcId }
          if (!tItem[0].nil?)
            configs << tItem[0]
          end
        end
      end

      render :json => configs
    rescue
      render :json => []
    end
  end

  # Get files for folder
  # Input from GET['fname']
  # Output json string
  def get_files_for_folders

    if (@currentSession.nil?)
      render :json => {:status => "failure", :message => "unauthorized"}
      return
    end

    # app id from session
    app = session[:accessible_app].to_s[0..7]
    appid = session[:accessible_appid]

    # tArray = Array.new
    rHash = Hash.new
    rHash['name'] = 'root'
    rHash['path'] = '/'
    rHash['items'] = Array.new

    url = "#{Rails.root}/public/resources/#{app}/*"
    folders = get_all_subdirectories_of_directory(url)

    folders.each do |f|
      tHash = Hash.new

      tHash['name'] = File.basename(f)
      tHash['path'] = f.gsub("#{Rails.root}/public", "")
      tHash['parent'] = File.basename(File.expand_path('.', f))
      tHash['items'] = Array.new

      tHash['items'] << {'name' => 'upload', 'path' => '', 'fileid' => '', 'parent' => tHash['parent']}

      filter_regged_files("#{f}/*.{css,js,jpg,png,jpeg,gif,pdf,zip,rar}", tHash['path'], tHash['name'], appid).each do |frf|
        tHash['items'] << frf
      end

      subdirs = get_all_subdirectories_of_directory("#{f}/*")
      if (subdirs.length > 0)
        recursively_parse_directory(subdirs, tHash['items'], appid)
      end

      rHash['items'] << tHash
    end

    #tArray << filter_regged_files("#{Rails.root}/public/resources/css/*.css", "/resources/css", "css")
    #tArray << filter_regged_files("#{Rails.root}/public/resources/js/*.js", "/resources/js", "js")
    #tArray << filter_regged_files("#{Rails.root}/public/resources/imgs/*.{jpg,png,jpeg,gif}", "/resources/imgs", "img")

    render :json => rHash
  end

  # Handle sending password-reset email to user
  # DO NOT ALLOW AUTHENTICATED OR LOGGED-IN USER TO ACCESS
  # Params is "email"
  def send_forgot_password_email

    if (!@currentSession.nil?)
      render :json => {:status => "failure", :message => "unauthorized"}
      return
    end

    begin
      user = User.find_by_email(params[:email])

      if (!user.nil?)
        user.reset_perishable_token!
        token = user.perishable_token
        url = request.host_with_port
        UserMailer.reset_passwords_email(user, url, token).deliver
        render :json => {:status => 'success'}
      else
        render :json => {:status => 'failure', :message => 'that email is not right'}
      end

    rescue
      render :json => {:status => 'failure', :message => 'mail delivery service is unavailable at the moment'}
    end
  end

  # Handle password change operation
  # DO NOT ALLOW AUTHENTICATED OR LOGGED-IN USER TO ACCESS
  # Params are "requestCode", "newPassword" and "newPasswordConfirmation"
  def do_change_forgot_password

    if (!@currentSession.nil?)
      render :json => {:status => "failure", :message => "unauthorized"}
      return
    end

    begin
      user = User.find_by_perishable_token(params[:requestCode])

      if (!user.nil?)
        user.password = params[:newPassword]
        user.password_confirmation = params[:newPasswordConfirmation]

        if (user.save)
          render :json => {:status => 'success'}
        else
          err_messages = ''
          user.errors.full_messages.each do |t|
            err_messages << "#{t}<br />"
          end

          render :json => {:status => 'failure', :message => err_messages.html_safe}
        end
      else
        render :json => {:status => 'failure', :message => 'request code was not found'}
      end
    rescue
      render :json => {:status => 'failure', :message => 'an unknown error occurred'}
    end

  end

  # Get all users (Only administrator can do this)
  def get_list_of_all_users_by_filter
    begin
      if (@curUserRole == 'developer' ||
          @curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      state = ''
      foundUsers = User.select("id, email").where("email like ? and id <> ?", "%#{params[:email]}%",@current_user.id)
      siteUsers = SiteUser.find_all_by_sites_id(session[:accessible_appid])

      if (foundUsers.length > 0)
        siteUsers.each do |t|
          foundUsers = foundUsers.reject { |f| f.id == t.users_id }
        end
      end

      ifUser = User.find_by_email(params[:email])
      if (!ifUser.nil?)
        siteUser = SiteUser.first({ :conditions => ['users_id = ? and sites_id = ?', ifUser.id, session[:accessible_appid]] })
        if (!siteUser.nil?)
          state = 'exists'
        else
          state = 'nonexists'
        end
      else
        state = 'nonexists'
      end

      render :json => { :status => 'success', :data => foundUsers.map { |a| a.email }, :state => state }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # Send invitation email to user
  def send_invitation_email_to_user
    begin
      if (@curUserRole == 'developer' ||
          @curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      user = current_user
      url = request.host_with_port
      invitationHash = Digest::SHA256.hexdigest("#{params[:email].strip}#{Time.now.to_i.to_s}")
      curSite = Metadata.first({ :conditions => ['sites_id = ? and key = ?', session[:accessible_appid], 'preferences'] })

      if (!curSite.nil?)
        existingInvitation = Invitation.first({ :conditions => ['invitation_id = ? and sites_id = ? and accepted = ?', invitationHash, session[:accessible_appid], false ] })

        if (existingInvitation.nil?)
          # Create invitation in database
          Invitation.create!({
                                 :invitation_id => invitationHash,
                                 :email => params[:email].strip,
                                 :sites_id => session[:accessible_appid],
                                 :roles_id => params[:role]
                             })

          # Send an email to user
          siteProps = ActiveSupport::JSON.decode(curSite.value)
          UserMailer.invite_email(user, params[:email], siteProps['name'].strip, "#{url}/manager/cms/invitation/#{invitationHash}" ).deliver
        else
          raise "invitation exists and claimed by \"#{params[:email].strip}\""
        end

      else
        raise 'current site was not found'
      end

      render :json => { :status => 'success' }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # Get a list of assigned roles for profile
  def get_users_assigned_roles_for_profile
    begin
      if (@currentSession.nil?)
        render :json => {:status => "failure", :message => "unauthorized"}
        return
      end

      siteUsers = SiteUser.all({ :conditions => ['sites_id = ? and users_id = ?', session[:accessible_appid], UserSession.find.record.id] })

      tArray = Array.new
      siteUsers.each do |t|
        tRole = Role.find(t.roles_id)
        if (!tRole.nil?)
          tArray << tRole.name
        end
      end

      render :json => { :status => 'success', :data => tArray }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # Get a list of roles of users
  def get_users_assigned_roles
    begin
      if (@currentSession.nil?)
        render :json => {:status => "failure", :message => "unauthorized"}
        return
      end

      group_name_filterables = {
          'admin' => 'Administrator',
          'admin_reviewer' => 'Administrator Reviewer',
          'developer' => 'Developer',
          'developer_reviewer' => 'Developer Reviewer',
          'contentadmin' => 'Content Manager',
          'contentadmin_reviewer' => 'Content Manager Reviewer',
          'user' => 'User',
          'anonymous' => 'Anonymous'
      }

      siteUsers = SiteUser.all({ :conditions => ['sites_id = ? and users_id = ?', params[:sites_id], UserSession.find.record.id]})

      tArray = Array.new
      siteUsers.each do |t|
        tRole = Role.find(t.roles_id)
        group_name_filterables.keys.each do |k|
          if (tRole.name == k)
            tRole.name = group_name_filterables[k].strip
            break
          end
        end
        tArray << tRole
      end

      render :json => { :status => 'success', :data => tArray }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # Assign users to different roles
  def set_user_assigned_role
    begin
      if (@curUserRole == 'developer' ||
          @curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      users_id = params[:users_id]
      roles_id = params[:roles_id]

      # Check if role has already been assigned?
      assignedYet = SiteUser.first({ :conditions => ['sites_id = ? and users_id = ? and roles_id = ?', session[:accessible_appid], users_id.to_i, roles_id.to_i ]})

      # if not, assign new role to user
      if (assignedYet.nil?)
        SiteUser.create({
                            :sites_id => session[:accessible_appid],
                            :users_id => users_id.to_i,
                            :roles_id => roles_id.to_i
                        })

        render :json => { :status => 'success' }
      else
        render :json => { :status => 'failure', :message => 'role has already been assigned to user' }
      end
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # Get list of users by group
  # Input
  # Output
  def get_list_users_by_group
    # Manually secure this service for administrator only
    begin

      if (@curUserRole == 'developer' ||
          @curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      usersGroup = params[:groupId].to_i

      app = session[:accessible_appid]
      siteUsers = SiteUser.all({:conditions => ['sites_id = ? and users_id <> ?', app, session[:accessible_userid]]})

      tArray = Array.new
      if (!usersGroup.nil?)
        siteUsers.each do |u|
          tUser = User.select('id, login, email').where('id = ?', u.users_id).first

          if (!tUser.nil?)
            if (u.roles_id == usersGroup)
              tArray << tUser
            end
          end
        end

        render :json => {:status => 'success', :data => tArray}
      else
        render :json => {:status => 'success', :data => []}
      end
    rescue Exception => ex
      render :json => {:status => 'failure', :message => ex.message}
    end
  end

  # Get user's sites
  def get_users_sites
    # Manually secure this service for administrator only
    begin

      if (@curUserRole == 'developer' ||
          @curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      render :json => {:status => 'success', :data => get_users_applications}
    rescue Exception => ex
      render :json => {:status => 'failure', :message => ex.message}
    end
  end

  # Get site information
  def get_site_information

    # Manually secure this service for administrator only
    begin

      if (@curUserRole == 'developer' ||
          @curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      key = params[:key]
      siteid = params[:siteid]

      site = Metadata.first({:conditions => [
          'sites_id = ? and cat = ? and key = ?', siteid, 'site', key
      ]})

      if (!site.nil?)
        render :json => {:status => 'success', :data => site}
      else
        render :json => {:status => 'failure'}
      end
    rescue Exception => ex
      render :json => {:status => 'failure', :message => ex.message}
    end
  end

  # Create site
  def create_site
    # Manually secure this service for administrator only
    # Whosoever creates site, that person becomes the owner
    # Should only disallow anonymous
    begin

      if (@curUserRole == 'anonymous')
        raise 'unauthorized access'
      end

      # First, create site
      site = Site.create({:sites_id => ''})
      Site.update(site.id, {:sites_id => Digest::SHA256.hexdigest(site.id.to_s)})

      # Second, associate site with current user
      currentUserId = @currentSession.record.id
      role = Role.find_by_name('admin')
      SiteUser.create({:users_id => currentUserId, :sites_id => site.id, :is_owner => true, :roles_id => role.id})

      # Third, create metadata entry
      Metadata.create({:key => 'preferences',
                       :cat => 'site',
                       :value => {
                           :name => params[:name],
                           :description => params[:description]
                       }.to_json,
                       :mime => 'text/plain',
                       :sites_id => site.id
                      })

      # Last, create directories
      Metadata.create({
                          :cat => "config",
                          :key => "currentLocale",
                          :value => "en_US",
                          :mime => "text/plain",
                          :sites_id => site.id
                      })
      Metadata.create({
                          :cat => "config",
                          :key => "autoLanguageSwitch",
                          :value => "no",
                          :mime => "text/plain",
                          :sites_id => site.id
                      })
      Metadata.create({
                          :cat => "locale",
                          :key => "english/US",
                          :value => "en_US",
                          :mime => "text/plain",
                          :sites_id => site.id
                      })
      Metadata.create({
                          :cat => "locale",
                          :key => "vietnamese/VN",
                          :value => "vi_VN",
                          :mime => "text/plain",
                          :sites_id => site.id
                      })

      # Last, create upload folders
      userRootPath = "#{Rails.root}/public/resources/#{Digest::SHA256.hexdigest(site.id.to_s).to_s[0..7]}"
      if (!File.directory?(userRootPath))
        Dir.mkdir userRootPath
      end
      if (!File.directory?("#{userRootPath}/downloads"))
        Dir.mkdir "#{userRootPath}/downloads"
      end
      if (!File.directory?("#{userRootPath}/js"))
        Dir.mkdir "#{userRootPath}/js"
      end
      if (!File.directory?("#{userRootPath}/css"))
        Dir.mkdir "#{userRootPath}/css"
      end
      if (!File.directory?("#{userRootPath}/imgs"))
        Dir.mkdir "#{userRootPath}/imgs"
      end

      render :json => {:status => "success"}
    rescue Exception => ex
      render :json => {:status => "failure", :message => ex.message}
    end
  end

  # Delete site
  def delete_site
    # Only allow 'admin' to access
    begin
      if (@curUserRole == 'developer' ||
          @curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      site = Site.find(params[:id])

      if (!site.nil?)
        siteid = site.sites_id.to_s[0..7]

        # Remove all resources folders and files
        filePath = "#{Rails.root}/public/resources/#{siteid}"
        FileUtils.rm_rf(filePath)

        # Remove site
        site.destroy

        # if the deleted site is the site that is currently used, log out and redirect to manager home page
        if (params[:id] == session[:accessible_appid])
          reset_session
          render :json => { :status => "redirect", :url => "/manager/cms/apps" }
          return
        end

        render :json => { :status => "success" }
      else
        render :json => { :status => "failure", :message => "site doesn't exist"}
      end
    rescue Exception => ex
      render :json => { :status => "failure", :message => ex.message}
    end
  end

  # CAPTCHA SECTION
  def generate_captcha
    if (request.xhr?)
      firstNum = rand(100)
      secondNum = rand(100)
      session[:captcha_answer] = firstNum + secondNum
      render :json => { :status => "success", :data => "What is the result of #{firstNum.to_s}+#{secondNum.to_s}?" }
    else
      render :json => { :status => "failure", :message => "access denied" }
    end
  end

  def verify_captcha
    if (request.xhr?)
      if (!session[:captcha_answer].nil?)
        if (params[:captcha].to_s == session[:captcha_answer].to_s)
          render :json => { :status => "passed" }
          reset_session
        else
          render :json => { :status => "failed" }
        end
      else
        render :json => { :status => "failure", :message => "captcha expired or non-existent" }
      end
    else
      render :json => { :status => "failure", :message => "access denied" }
    end
  end
  # END

  # METADATA HISTORY
  def get_metadata_history
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      offset = params[:offset].to_i

      item = Metadata.find(params[:id].to_i)

      versions = item.versions.reject { |t| t[:object].nil? == true }

      versions.each do |t|
        if (!t[:whodunnit].nil?)
          username = User.find(t.whodunnit)
          t[:whodunnit] = username.login
        end
      end

      versions = versions.reverse

      if (!item.nil?)
        render :json => { :status => 'success', :data => versions.drop(offset).take(5).reverse, :latest => item.updated_at, :nav => { :current => (offset.to_f / 5).ceil + 1, :max => (versions.length.to_f / 5).ceil } }
      else
        render :json => { :status => 'success', :data => [] }
      end

    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  def get_metadata_history_item
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      item = Metadata.find(params[:id])

      if (!item.nil?)
        archived = item.version_at(DateTime.parse(params[:date]))

        render :json => { :status => 'success', :data => archived.nil? ? nil : archived }
      else
        render :json => { :status => 'success', :data => nil }
      end

    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end
  # END

  # METADATA ARCHIVING
  def get_metadata_archives
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      offset = 2
      max = 0
      queryNum = params[:maxPerPage].nil? || params[:maxPerPage].empty? ? 10 : params[:maxPerPage].to_f
      page = params[:page].to_i
      items = Array.new

      if (page - 1 >= 0)
        items = Metadata.archived.find(:all, :conditions => ['sites_id = ?', session[:accessible_appid] ])
        items = items.sort_by { |t| t.updated_at }
        items.each do |t|
          version = Version.all({ :conditions => ['item_id = ? and event = ?', t.id, 'update'], :order => 'created_at desc', :limit => 1 })
          if (version.count > 0)
            if (version[0].whodunnit.to_i == session[:accessible_userid])
              t['hide'] = true
            else
              t['hide'] = false
            end
          end
        end

        max = (items.count.to_f / queryNum).ceil
        items = items.drop((page - 1)*offset).take(queryNum)
      else
        page = 0
        max = 0
      end

      render :json => { :status => 'success', :data => items, :extra => { :cur => page, :max => max } }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end
  # END

  private

end