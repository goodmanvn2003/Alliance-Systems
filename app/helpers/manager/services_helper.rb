module Manager::ServicesHelper

  def ensure_local_login
    @currentSession = UserSession.find
  end

  # Get the first metadata based on id and prepare it
  # Input id (as number)
  # Output nil or valid data
  def prepare_one_by_id(app, query)

    if (!query.empty? && !query.nil?)
      data = Metadata.where("id = ? and sites_id = ?", query, app).first

      data.nil? ? nil : data
    else
      data = nil
    end
  end

  # Get the first metadata based on key and category and prepare it
  # Input query (key as string) and category (cat as string)
  # Output nil or valid data
  def prepare_one_by_key(app, query, category)
    if (!query.empty? && !query.nil?)
      data = Metadata.where("key = ? and cat = ? and sites_id = ?", query, category, app).first

      data.nil? ? nil : data
    else
      data = nil
    end
  end

  def prepare_one_by_value(app, query, category)
    if (!query.empty? && !query.nil?)
      data = Metadata.where("value = ? and cat = ? and sites_id = ?", query, category, app).first

      data.nil? ? nil : data
    else
      data = nil
    end
  end

  # (Duplicated) Check, filter and output a list of registered files based on file path
  def filter_regged_files(directory, relativePath, cat, appid)
    tArray = Array.new
    files = Dir.glob(directory)
    files.each do |t|
      tHash = Hash.new
      tHash['name'] = File.basename(t.strip)
      tHash['path'] = "#{relativePath}/#{tHash['name']}"
      tHash['parent'] = File.basename(File.expand_path('.', "#{Rails.root}/public#{relativePath}"))

      #if (cat == "imgs")
      #  tArray << tHash
      #elsif (cat == "downloads")
      #  tArray << tHash
      #else

      regFile = Metadata.where("value = ? and sites_id = ?", tHash['path'], appid).first
      # If the file is not registered, it's not visible
      if (!regFile.nil?)
        tHash['fileid'] = regFile.key.strip
        tArray << tHash
      else
        tHash['fileid'] = ''
        tArray << tHash
      end

      #end
    end
    tArray
  end

  def get_all_subdirectories_of_directory(directory)
    begin
      Dir.glob(directory).select { |dir| File.directory?(dir) }
    rescue
      []
    end
  end

  def recursively_parse_directory(folder, hash, appid)
    folder.each do |f|
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

      hash << tHash
    end
  end

  # Get a list of applications of users
  def get_users_applications

    if (UserSession.find.nil?)
      raise "[Err] User is not logged in"
    end

    userSites = SiteUser.find_all_by_users_id(UserSession.find.record.id).map { |t| t.sites_id }.uniq

    tArray = Array.new
    userSites.each do |t|
      tSiteMetadata = Metadata.find_by_sites_id(t.to_s)
      tSiteMetadataPrefs = ActiveSupport::JSON.decode(tSiteMetadata.value)

      if (!tSiteMetadata.nil?)
        tHash = Hash.new
        tHash['id'] = tSiteMetadata.sites_id.to_s
        tHash['name'] = tSiteMetadataPrefs['name'].strip

        tArray << tHash
      end
    end
    return tArray
  end

end