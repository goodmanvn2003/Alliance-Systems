Podioror::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  get '/' => 'home#index'
  match '/:app' => 'home#display', :tpl => 'index'
  match '/:app/:tpl' => 'home#display', :constraints => { :app => /(?!manager\b|upload\b|auth\b)\b\w+/ }

  # Download route
  get '/:app/client/dl/:filename' => 'home#serve' , :constraints => { :app => /(?!manager\b|upload\b|auth\b)\b\w+/, :filename => /([a-zA-Z0-9\-\_]+\.[a-z]{1,3})/}

  # Upload route
  post '/upload' => 'upload#uploadFile'
  delete '/upload/del' => 'upload#deleteFile'
  post '/upload/save' => 'upload#saveTextFile'
  get '/upload/file' => 'upload#getFile'
  
  # Management routes
  namespace :manager do

  	get 'cms' => 'manager#login'
    get 'cms/invitation/:invitation_id' => 'manager#register'
    get 'cms/apps' => 'manager#select_application'
  	get 'cms/pages' => 'manager#pages'
  	get 'cms/elements' => 'manager#elements'
  	get 'cms/configure' => 'manager#configure'
  	get 'cms/files' => 'manager#file_manager'
  	get 'cms/contentlib' => 'manager#contentlib'
  	get 'cms/system' => 'manager#system'
    get 'cms/users' => 'manager#users'
    get 'cms/profile' => 'manager#user_profile'
    get 'cms/extensions' => 'manager#extensions'
    get 'cms/sites' => 'manager#sites'
    get 'cms/archives' => 'manager#archives'
  
  	resources :configurations
    delete 'configurations/purge/:id' => 'configurations#destroy_permanently'
    post 'configurations/restore/:id' => 'configurations#restore'

    resources :users
    post 'users/only' => 'users#create_user_only'
    put 'users/self/info' => 'users#update_self'
    put 'users/role/:id' => 'users#update_role'
    get 'users/activate/:code' => 'users#activate_user'

    resources :invitations

    resources :site_users
  	
  	# Servicing routes
  	get 's/i/:id' => 'services#fetch_one_by_id'
  	get 's/g/:key/:cat' => 'services#fetch_one_by_key', :constraints => { :key => /[0-9A-Za-z\-_\.]+/ }
    get 's/v/:value/:cat' => 'services#fetch_one_by_value'
  	# get 's/c/:cat' => 'services#fetch_all_by_cat'
  	get 's/pl/:cat' => 'services#fetch_all_placeholders_of_template'
  	get 's/item/:destId/:srcId' => 'services#set_active_item'
  	get 's/ritem/:destId/:srcId' => 'services#remove_active_item'
  	get 's/items/:tpl' => 'services#get_items_of_template'
    get 's/items/list/:cat' => 'services#get_list_of_configuration_items_by_cat'
    get 's/items/list/assoc/:item/:cat' => 'services#get_list_of_configuration_items_by_assoc'
    get 's/items/list/rassoc/:item/:cat' => 'services#get_list_of_configuration_items_by_assoc_in_reverse'
  	get 'files' => 'services#get_files_for_folders'
    post 'u/services/request_pass_reset' => 'services#send_forgot_password_email'
    post 'u/services/do_pass_reset' => 'services#do_change_forgot_password'
    get 'r/services/list_profile' => 'services#get_users_assigned_roles_for_profile'
    get 'r/services/list/:sites_id' => 'services#get_users_assigned_roles'
    put 'r/services/assign/:users_id' => 'services#set_user_assigned_role'
    get 'u/services/list/:groupId' => 'services#get_list_users_by_group'
    post 'u/services/list/filter' => 'services#get_list_of_all_users_by_filter'
    post 'u/services/invite' => 'services#send_invitation_email_to_user'
    get 'site/services/all' => 'services#get_users_sites'
    get 'site/services/info/:siteid/:key' => 'services#get_site_information'
    post 'site/services/create' => 'services#create_site'
    delete 'site/services/delete/:id' => 'services#delete_site'
    get 'h/items/:id' => 'services#get_metadata_history'
    get 'h/item/:id/:date' => 'services#get_metadata_history_item'
    get 'h/archived/:page' => 'services#get_metadata_archives'

    # Captcha
    get 'captcha/services/generate' => 'services#generate_captcha'
    post 'captcha/services/verify' => 'services#verify_captcha'
  end

  # OpenID Routes
  post 'auth/local' => 'user_sessions#authenticate'
  get 'auth/local/delete' => 'user_sessions#logout'
  post 'auth/local/client' => 'user_sessions#client_authenticate'
  post 'auth/local/app' => 'user_sessions#set_active_application'
  post 'auth/local/invitation' => 'user_sessions#create_user_with_invitation'

  # Mount all known engines
  # mount AlliancePodioMountable::Engine, :at => "/podio_engine"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#display', :tpl => 'index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
