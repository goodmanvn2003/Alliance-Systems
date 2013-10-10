module Manager::ManagerHelper

  # Check site access
  def site_access
    if (session[:accessible_app].nil? || session[:accessible_app].empty?)
      raise '[Err] No site was specified'
    end
    if (session[:accessible_roleid].nil? || session[:accessible_roleid].empty?)
      raise '[Err] No role for current user was specified'
    end
  end

  # Get a list of applications of users
  def get_users_applications

    if (UserSession.find.nil?)
      raise "[Err] User is not logged in"
    end

    # user = User.find(UserSession.find.record.id)
    userSites = SiteUser.find_all_by_users_id(UserSession.find.record.id).map { |t| t.sites_id }.uniq

    tArray = Array.new
    userSites.each do |t|
      tSiteMetadata = Metadata.find_by_sites_id(t.to_s)

      if (!tSiteMetadata.nil?)
        tSiteMetadataPrefs = ActiveSupport::JSON.decode(tSiteMetadata.value)
        tHash = Hash.new
        tHash['id'] = tSiteMetadata.sites_id.to_s
        tHash['name'] = tSiteMetadataPrefs['name'].strip

        tArray << tHash
      end
    end
    return tArray
  end

end