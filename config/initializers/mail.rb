ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address               => "smtp.gmail.com",  # Your SMTP host
    :port => 587,
    :authentication        => "plain",
    # :domain                => "localhost",
    :user_name             => "[username]",
    :password              => "[password]",
    :enable_starttls_auto  => true
}