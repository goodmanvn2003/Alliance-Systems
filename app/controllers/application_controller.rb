class ApplicationController < ActionController::Base
  #protect_from_forgery

  @@abbrErr = "APP"

  # if config.consider_all_requests_local is false, will capture all errors. Some error templates are in public folder

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :show_error_500
  end

  before_filter :manage_browser, :called_controller

  protected

  # Internal protected methods
  def manage_browser
    logger.debug(detect_browser)
  end

  def called_controller
    @called = request.referrer
  end
  # END

  private

  # Should be tested to see if all raised exceptions are caught and shown to developers/users

  def show_error_500(exception)
    render :template => '/errors/500.html.erb', :layout => 'error', :status => 500, :locals => {
        :msg => !exception.nil? ? "#{exception.message}" : "", :status => 500
    }
  end

  # Detect and redirect to mobile feature

  MOBILE_BROWSERS = ["playbook", "windows phone", "android", "ipod", "iphone", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def detect_browser
    agent = request.headers["HTTP_USER_AGENT"].downcase

    MOBILE_BROWSERS.each do |m|
      return "mobile" if agent.match(m)
    end
    return "desktop"
  end

end
