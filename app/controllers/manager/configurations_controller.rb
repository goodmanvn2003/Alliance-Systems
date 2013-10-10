class Manager::ConfigurationsController < ApplicationController
  include ApplicationHelper

  layout nil

  before_filter :get_current_user_role

  # POST config
  def create
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      # Filter specific type of creation request
      mtype = params[:type]

      # Model fields
      mkey = params[:key]
      mvalue = params[:value]
      mcat = params[:cat]
      mmime = params[:mime]

      # Multiple site features
      mapp = session[:accessible_appid]
      # end

      # Check duplication by type
      if (mtype != "locale")
        if (!Metadata.first({:conditions => ['key = ? and sites_id = ?', mkey, mapp]}).nil?)
          render :json => {:status => 'failure', :data => {:key => mkey, :value => mvalue}, :message => 'the key was duplicated'}
          return
        end
      elsif (mtype == "locale")
        # get a list of locale items
        localeItems = MetadataAssociation.find_all_by_destId(params[:locale].to_i).map { |i| i.destId }

        if (localeItems.length > 0)
          # try to retrieve article or label item by category
          item = Metadata.where('key = ? and cat = ? and sites_id = ?', mkey, mcat, mapp)

          # Get request locale name
          locale = Metadata.find(params[:locale].to_i)

          # try to check duplication of article or label in a locale
          if (item.length > 0)
            item.each do |tl|
              associated = MetadataAssociation.find_by_srcId(tl.id)
              associatedLocale = Metadata.find(associated.destId)

              if (associatedLocale.value == locale.value)
                render :json => {:status => 'failure', :data => {:key => mkey, :value => mvalue}, :message => 'the key was duplicated'}
                return
              end
            end
          end

        end
      end

      # Create metadata
      if (!mkey.nil? && !mvalue.nil? && !mcat.nil? && !mmime.nil?)
        metadata = Metadata.create({
                                       :key => mkey,
                                       :value => mvalue.html_safe,
                                       :cat => mcat,
                                       :mime => mmime,
                                       :sites_id => mapp
                                   })
        # create the record(s)
        # metadata.save
      else
        render :json => {:status => 'failure', :data => {:key => mkey, :value => mvalue}, :message => 'there was an unknown error, please contact system administrator'}
        return
      end

      # If the specific request is "page", should create an association with metadata
      if (mtype == "page")
        # Specific page creation variable
        mtpl = params[:tpl]
        # Don't associate template with page if server receives no specific template from client
        if (!mtpl.nil?)
          MetadataAssociation.new do |ma|
            ma.srcId = metadata.id
            ma.destId = mtpl.to_i

            ma.save
          end
        end
      # If the specific request is "locale", should create an association with metadata
      elsif (mtype == "locale")
        locale = params[:locale]

        if (!locale.nil?)
          MetadataAssociation.new do |ma|
            ma.srcId = metadata.id
            ma.destId = locale.to_i

            ma.save
          end
        end
      else
        # Awaiting more cases
      end

      render :json => {:status => 'success', :data => {:key => mkey, :value => mvalue, :newid => metadata.id}}
    rescue Exception => ex
      render :json => {:status => 'failure', :data => {:key => mkey, :value => mvalue}, :message => ex.message}
    end
  end

  # PUT config(:id => 1)
  def update
    # find and update a specific metadata
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      id = params[:id]
      dataObj = params[:data]

      # Required for audit
      time = params[:time]

      # Required for some cases
      affectedCategory = ['page','template','placeholder','meta','ruby']
      flag = params[:flag]
      extra = {}
      #

      if (!dataObj.nil?)
        # Audit should go here if enabled
        if (defined?(CompliancePlugin))
          begin
            extraData = CompliancePlugin::ComplianceOperations.update(id, dataObj, @current_user.id, affectedCategory, session[:accessible_appid], time)
            extra = { :compliance_status => extraData }
          rescue Exception => ex
            if (ex.message != "fallback")
              raise ex.message
            else
              Metadata.update(id, dataObj);
              extra = { :compliance_status => "saved" }
            end
          end
        else
          Metadata.update(id, dataObj)
          extra = { :compliance_status => "saved" }
        end

      end

      if (flag == "page")
        destId = params[:tpl]
        meta = MetadataAssociation.first({ :conditions => ['srcId = ? and destId = ?',id , destId.to_i] })

        if (meta.nil?)
          MetadataAssociation.delete_all(["srcId = ?", id])

          MetadataAssociation.new do |ma|
            ma.srcId = id
            ma.destId = destId.to_i
            ma.save
          end
        end
      elsif (flag == "site")
        # if current site info is changed, update session
        if (session[:accessible_appid].to_i == Metadata.find(params[:id].to_i).sites_id)
          siteJson = ActiveSupport::JSON.decode(dataObj.to_hash['value'])
          session[:accessible_appname] = siteJson['name']
          extra['new_sitename'] = siteJson['name']
        end
      end

      render :json => {:status => 'success', :data => {:id => id.to_s}, :extra => extra }
    rescue Exception => ex
      render :json => {:status => 'failure', :data => {:id => id.to_s}, :message => ex.message}
    end
  end

  # DELETE config(:id => 1)
  def destroy
    # delete a specific metadata
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      affectedCategory = ['page','template','placeholder','meta','ruby']
      mid = params[:id]
      mtype = params[:type]

      if (!mid.nil?)
        metadata = Metadata.find(mid)

        # Do extra jobs
        if (mtype == 'locale')
          # Delete all the things related to this locale
          metadataItems = MetadataAssociation.find_all_by_destId(mid)
          metadataItems.each do |t|
            Metadata.find(t.srcId).destroy
          end
        end

        # Finally, delete the record
        # Don't just destroy, archive it if compliance plugin is enabled
        if (defined?(CompliancePlugin))
          CompliancePlugin::ComplianceOperations.destroy(session[:accessible_appid], affectedCategory, metadata)
        else
          metadata.destroy
        end

        render :json => {:status => 'success', :data => {:id => mid}, :metadata => metadata.to_json}
      else
        render :json => {:status => 'failure', :data => {:id => mid}, :message => 'Nothing to delete'}
      end
    rescue Exception => ex
      render :json => {:status => 'failure', :data => {:id => mid}, :message => ex.message}
    end
  end

  # DELETE config(:id => 1) {{ PERMANENTLY }}
  def destroy_permanently
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      CompliancePlugin::ComplianceOperations.destroy_permanently(params[:id])

      render :json => { :status => 'success' }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  # POST restore_item
  def restore
    begin
      if (@curUserRole == 'user' ||
          @curUserRole == 'anonymous' ||
          @curUserRole == 'loggedin')
        raise 'unauthorized access'
      end

      CompliancePlugin::ComplianceOperations.restore(params[:id])

      render :json => { :status => 'success' }
    rescue Exception => ex
      render :json => { :status => 'failure', :message => ex.message }
    end
  end

  private

end