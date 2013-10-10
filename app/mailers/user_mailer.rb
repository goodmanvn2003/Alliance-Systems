class UserMailer < ActionMailer::Base
  default from: "webmaster@ngonluakiko.com"

  def reset_passwords_email(user,url,token)
    @user = user
    @url = url
    @token = token
    mail(:to => @user.email, :subject => '[Alliance-CMS] Password Reset')
  end

  def activate_account_email(user, url)
    @user = user
    @url = url
    mail(:to => @user.email, :subject => '[Alliance-CMS] Account Activation')
  end

  def invite_email(user, email, workspace, url)
    @user = user
    @workspace = workspace
    @url = url
    mail(:to => email, :subect => '[Alliance-CMS] Invitation')
  end
end
