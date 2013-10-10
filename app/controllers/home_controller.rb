class HomeController < ApplicationController
  respond_to :html
  include LoadersUtility, HomeHelper
  layout 'application'

  if (defined?(AlliancePodioPlugin))
    before_filter :ensure_login
  end

  skip_before_filter :ensure_login, :only => [
      :serve
  ]

  def index
    redirect_to '/manager/cms'
  end

  def display
    query = params[:tpl].to_s
    app = params[:app].to_s
    cookies[:url] = request.original_url

    # Find site id with the given hash
    appid = find_site app
    if (appid == nil)
      raise "[Err] The resource you are looking for doesn't exist"
    else
      siteInfo = Metadata.first({ :conditions => ['cat = ? and key = ? and sites_id = ?', 'site', 'preferences', appid]})
      @appName = ActiveSupport::JSON.decode(siteInfo.value.strip)['name'].nil? ? '' : ActiveSupport::JSON.decode(siteInfo.value.strip)['name'].strip
      @appDescription = ActiveSupport::JSON.decode(siteInfo.value.strip)['description'].nil? ? '' : ActiveSupport::JSON.decode(siteInfo.value.strip)['description'].strip
    end

    tPage = get_page query, appid
    tTemplate = get_template tPage, appid
    tTemplateBody = tTemplate.value.strip
    tTemplateBody = parse_placeholders tPage, tTemplateBody, appid
    tTemplateBody = parse_language_items tTemplateBody, appid
    tTemplateBody = parse_scripts tTemplateBody, appid

    # Get all metadata
    all_metadata = Metadata.all({ :conditions => [
        'sites_id = ?', appid
    ]})

    # Output stuffs
    @body = tTemplateBody

    # Load associated meta tags
    @metas = load_meta_tags tTemplate, all_metadata, appid

    # Load associated css
    @css = load_css tTemplate, all_metadata, appid

    # Load associated javascripts
    @js = load_js tTemplate, all_metadata, appid

    # Show warnings if any
    warnings = @body.scan(/\{\{[a-zA-Z0-9-_'",.\[\]\(\)\*\+`~!@#\$%^&|\\\/:=\s]+\}\}/)
    if (warnings.length > 0)
      warningText = '<ul style="background:red;margin:0;padding:10px;">'

      warnings.each do |w|
        # Show warnings and clean up the content
        warningText << "<li>#{w.gsub('{{','').gsub('}}','')}</li>"
        @body = @body.gsub(w,'')
      end

      warningText << '</ul>'
      flash[:systemWarning] = warningText
    end

    respond_with :action => "display"
  end

  def serve

    filename = params[:filename]
    app = params[:app]

    downloadFolder = "#{Rails.root}/public/resources/#{app}/downloads/"
    downloadFile = "#{downloadFolder}#{filename}"

    if (Dir.exists?(downloadFolder))
      if (!File.exists?(downloadFile))
        raise "[Err] The download file doesn\'t exist"
      else
        send_file(downloadFile)
      end
    else
      raise "[Err] The download folder doesn\'t exist"
    end

  end

  protected

  # PODIO plugin
  def ensure_login
    appid = session[:accessible_appid]

    if session[:podio_access_token]
      # Get service user account information from database
      usrName = Metadata.where("key = ? and sites_id = ?", "serviceAccountName", appid).first
      usrPass = Metadata.where("key = ? and sites_id = ?", "serviceAccountPass", appid).first

      if (!usrName.nil? && !usrPass.nil?)
        if cookies[:podio].to_s == Digest::SHA2.hexdigest("#{usrName.value.strip}#{usrPass.value.strip}")
          init_podio_client
        else
          redirect_to "/podio/auth/podio_as_user"
        end
      else
        # flash[:systemWarnings] << "[alliance-podio] Since you use podio integration plugin, a service account must be used<br />"
      end
    else
      redirect_to "/podio/auth/podio_as_user"
    end
  end

  def init_podio_client
    appid = session[:accessible_appid]

    apiKey = Metadata.first({:conditions => ["key = ? and sites_id = ?", "podioApiKey", appid]
                            })
    secretKey = Metadata.first({:conditions => ["key = ? and sites_id = ?", "podioSecretKey", appid]
                               })
    if (!apiKey.nil? && !secretKey.nil?)
      Podio.setup(
          :api_url => 'https://api.podio.com',
          :api_key => apiKey.value.strip,
          :api_secret => secretKey.value.strip,
          :oauth_token => Podio::OAuthToken.new('access_token' => session[:podio_access_token], 'refresh_token' => session[:podio_refresh_token])
      )
    else
      # Don't do anything
    end
  end

  # Utility methods
  private

end

