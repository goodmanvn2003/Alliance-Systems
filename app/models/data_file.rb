class DataFile < ActiveRecord::Base
  def self.save(upload, category, fpath, app)

    name = upload['datafile'].original_filename
    directory = "#{Rails.root}/public/resources#{fpath}"
    # sanitize the filename (just in case)
    filename = sanitize_filename(name)
    # create the file path
    path = File.join(directory, filename)
    # write the file

    if (["png", "gif", "jpg", "jpeg"].include? category)
      mime = "image/#{category}"
    elsif (category == "js")
      mime = "text/javascript"
    elsif (category == "css")
      mime = "text/stylesheet"
    elsif (["pdf", "zip", "rar"].include? category)
      mime = "application/octet-stream"
    else
      raise "extension not allowed"
    end

    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }

    if (category == "js" || category == "css")
      if (Metadata.first({:conditions => [ 'key = ? and cat = ? and sites_id = ?', File.basename(filename, File.extname(filename)), category, app ]}).nil?)
        Metadata.create({
                            :key => File.basename(filename, File.extname(filename)),
                            :value => "/resources#{fpath}/#{filename}",
                            :mime => mime,
                            :cat => category,
                            :sites_id => app
                        }).save
      end
    end
  end

  private

  def self.sanitize_filename(file_name)
    # get only the filename, not the whole path (from IE)
    just_filename = File.basename(file_name)
    # replace all none alphanumeric, underscore or perioids
    # with underscore
    just_filename.sub(/[^\w\.\-]/, '_')
  end
end
