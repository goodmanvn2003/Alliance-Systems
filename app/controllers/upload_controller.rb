class UploadController < ApplicationController
  include ApplicationHelper

  layout nil
  before_filter :get_current_user_role

  # access_control do
  #  allow :admin
  #  allow :developer

  #  deny :user
  # end

  def uploadFile
    begin
      if (@curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      category = params[:fileCategory].strip
      appPath = session[:accessible_app].to_s[0..7]
      path = "/#{appPath}#{params[:filePath].strip}"
      # Get current app
      app = session[:accessible_appid]
      post = DataFile.save(params[:fileUpload], category, path, app)
      render :json => {:status => "success", :uploadedFolder => category}
    rescue Exception => ex
      render :json => {:status => "failure", :message => ex.message}
    end
  end

  def deleteFile
    begin
      if (@curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      file = params[:file]
      fileCat = params[:fileCat]
      fileId = params[:fileId]
      app = session[:accessible_appid]
      full_filename = "#{Rails.root}/public#{file}"

      if (File.exists?(full_filename))
        File.delete(full_filename)

        begin
          metadata = Metadata.where("key = ? and cat = ? and sites_id = ?", fileId, fileCat, app).first

          if (!metadata.nil?)
            metadata.destroy
          end
        rescue
          # don't do anything
        end
      end

      render :text => "success"
    rescue
      render :text => "failure"
    end
  end

  # Should check if the file exists and get the content of the file in plain text
  def getFile
    begin
      if (@curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      file = params[:file]
      full_filename = "#{Rails.root}/public/#{file}"

      output = ''
      if (File.exists?(full_filename))
        File.open(full_filename, "r").each do |line|
          output << line
        end
      else
        raise "exception"
      end

      render :text => output
    rescue
      render :text => "failure", :status => 500
    end
  end

  # The file is to be overwritten
  def saveTextFile
    begin
      if (@curUserRole == 'contentadmin' ||
          @curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      file = params[:file]
      file_content = params[:fileContent]
      full_filename = "#{Rails.root}/public#{file}"

      if (File.exists?(full_filename))
        result = File.open(full_filename, 'w') { |f| f.write(file_content.strip) }

        render :text => "success"
      else
        render :text => "failure"
      end
    rescue
      render :text => "failure"
    end
  end

  private

end
