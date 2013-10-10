module UserSessionsHelper

  def create_default_user_with_app(login, password, password_confirmation, email, app, app_desc)
    flag = false
    params = Hash.new
    params[:user] = Hash.new
    params[:user]["login"] = login
    params[:user]["password"] = password
    params[:user]["password_confirmation"] = password_confirmation
    params[:user]["email"] = email

    user = User.new(params[:user])
    # user.active = true
    user.reset_persistence_token
    if (user.valid?)
      if (user.save)

        flash[:success] = 'Since you were the first to log in, the provided information was used to create the default account. <br /> You can now use it to log in'
        flash[:login] = login

        # Since this is the first created account, its session must be cleared
        if (!UserSession.find.nil?)
          UserSession.find.destroy
        end

        # Register the first application for the user
        # First, make a name for the site
        site = Site.create({:sites_id => ''
                           })
        Site.update(site.id, {:sites_id => Digest::SHA256.hexdigest(site.id.to_s)})

        Metadata.create({:key => 'preferences',
                         :value => {
                             :name => app.nil? ? '' : app.strip,
                             :description => app_desc.nil? ? '' : app_desc.strip
                         }.to_json,
                         :sites_id => site.id,
                         :mime => 'text/plain',
                         :cat => 'site',
                        })

        # Second, link the site with the user
        role = Role.find_by_name('admin')
        SiteUser.create({:users_id => user.id, :sites_id => site.id, :is_owner => true, :roles_id => role.id})

        # Third, create some default metadata for site
        index_page = Metadata.create({
                                         :cat => "page",
                                         :key => "index",
                                         :value => "<h2>Welcome to Alliance CMS</h2><div>This is a blank page, feel free to modify it!</div>",
                                         :mime => "text/html",
                                         :sites_id => site.id
                                     })
        sample_template = Metadata.create({
                                              :cat => "template",
                                              :key => "default",
                                              :value => "<h1>Alliance CMS</h1><div>[[body]]</div>",
                                              :mime => "text/html",
                                              :sites_id => site.id
                                          })
        MetadataAssociation.create({
                                       :srcId => index_page.id,
                                       :destId => sample_template.id
                                   })
        Metadata.create({
                            :cat => "config",
                            :key => "currentLocale",
                            :value => "en_US",
                            :mime => "text/plain",
                            :sites_id => site.id
                        })
        Metadata.create({
                            :cat => "config",
                            :key => "autoLanguageSwitch",
                            :value => "no",
                            :mime => "text/plain",
                            :sites_id => site.id
                        })
        Metadata.create({
                            :cat => "locale",
                            :key => "english/US",
                            :value => "en_US",
                            :mime => "text/plain",
                            :sites_id => site.id
                        })
        Metadata.create({
                            :cat => "locale",
                            :key => "vietnamese/VN",
                            :value => "vi_VN",
                            :mime => "text/plain",
                            :sites_id => site.id
                        })

        # Last, create upload folders
        userRootPath = "#{Rails.root}/public/resources/#{Digest::SHA256.hexdigest(site.id.to_s).to_s[0..7]}"
        if (!File.directory?(userRootPath))
          Dir.mkdir userRootPath
        end
        if (!File.directory?("#{userRootPath}/downloads"))
          Dir.mkdir "#{userRootPath}/downloads"
        end
        if (!File.directory?("#{userRootPath}/js"))
          Dir.mkdir "#{userRootPath}/js"
        end
        if (!File.directory?("#{userRootPath}/css"))
          Dir.mkdir "#{userRootPath}/css"
        end
        if (!File.directory?("#{userRootPath}/imgs"))
          Dir.mkdir "#{userRootPath}/imgs"
        end

        flag = true
      else
        flash[:err] = 'There was a problem when we tried to create your account for the first time'
        flash[:login] = login
      end

      if (flag)
        # Send an activation email to user only the user count is greater than 0
        UserMailer.activate_account_email(user, "#{request.host_with_port}/manager/users/activate/#{Digest::SHA256.hexdigest(user.id.to_s)}").deliver
      end

      redirect_to '/manager/cms'
    else

      err_messages = ''
      user.errors.full_messages.each do |t|
        err_messages << "#{t}<br />"
      end

      flash[:err] = err_messages
      flash[:login] = login
      redirect_to '/manager/cms'
    end

  end

end