module ApplicationHelper

  def isEnabledOfs?
    installedEngines = SystemModel.get_list_of_compatible_gems
    statusesEngines = Hash.new('Engine Statuses')

    installedEngines.each do |i|
      tHash = Hash.new

      engineModule = i.name.split('_').map(&:capitalize).join('')

      begin
        data = eval("#{engineModule}::Status").isEnabled?(session[:accessible_appid])
        tHash['status'] = data
        statusesEngines = statusesEngines.merge(engineModule => tHash)
      rescue LoadError => e1
      rescue NameError => e2
      end
    end

    @enginesFlags = statusesEngines
  end

  def current_user
    if UserSession.find.nil?
      @current_user ||= nil
    else
      if (UserSession.find.stale? == true)
        @current_user ||= nil
      else
        @current_user ||= User.find(UserSession.find.record.id)
      end
    end
  end

  # Get current user's role
  def get_current_user_role
    @current_user = current_user
    if (!@current_user.nil?)
      siteId = session[:accessible_appid]
      roleId = session[:accessible_roleid]

      if (!siteId.nil? && !roleId.nil?)
        userRole = Role.find(roleId)
        @curUserRole = userRole.name
      else
        @curUserRole = 'loggedin'
      end

    else
      @curUserRole = 'anonymous'
    end
  end

  def is_current_accessible?
    # Get current user id
    @current_user = current_user
    if (!@current_user.nil?)
      siteId = session[:accessible_appid]
      roleId = session[:accessible_roleid]

      if (!siteId.nil? && !roleId.nil?)
        userRole = Role.find(roleId)
      else
        raise 'unauthorized access (no sites)'
      end

      if (!userRole.name.include?('admin'))
        raise 'unauthorized access'
      end
    else
      raise 'unauthorized access (not logged in)'
    end
  end

end
