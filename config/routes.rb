Idlik12::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase


  resources :donors
  get 'friend',             to: 'gifts#friend',             as: :friend
  get 'select_friend',      to: 'gifts#select_friend',      as: :select_friend
  get 'index_for_friend',   to: 'gifts#index_for_friend',   as: :index_for_friend
  get 'index_for_registry', to: 'gifts#index_for_registry', as: :index_for_registry
  get 'gift_restore_owner', to: 'gifts#give_restore_owner', as: :give_restore_owner
  get 'give_gift',          to: 'gifts#give_gift',          as: :give_gift
  get 'copy_gift',          to: 'gifts#copy_gift',          as: :copy_gift

  resources :gifts do
    #get 'registry_toggle', to: 'gifts#registry_toggle', as: :registry_toggle
    get 'init_index',       to: 'gifts#init_index',         as: :init_index
  end

  resource :home
  get 'how',                to: 'home#how',                 as: :how
  get 'what',               to: 'home#what',                as: :what
  get 'faq',                to: 'home#faq',                 as: :faq
  get 'tell',               to: 'home#tell',                as: :tell
  get 'privacy',            to: 'home#privacy',             as: :privacy
  get 'terms',              to: 'home#terms',               as: :terms
  get 'advertise',          to: 'home#advertise',           as: :advertise
  get 'contact',            to: 'home#contact',             as: :contact

  resources :roles,         has_many: :users
  resources :registries
  resources :sources

  resources :user_sessions
  get 'login',              to: 'user_sessions#new',        as: :login
  get "logout",             to: 'user_sessions#destroy',    as: :logout
  get "signup",             to: 'user_sessions#new',        as: :new
  get "orient",             to: 'user_sessions#orient',     as: :orient


  resources :users do #,   has_many: [:registries, :roles, :gifts, :friends]
    get 'invite',             to: 'users#invite',             as: :invite
    get 'invitation',         to: 'users#invitation',         as: :invitation
    get 'accept_invite',      to: 'users#accept_invite',      as: :accept_invite
  end

  resources :users do    
    resources :gifts
    resources :registries
  end

  resources :gifts do
    resources :donors
  end

  resources :donors do
    resources :sources
  end


=begin
  get 'registry_toggle'    to: 'gift#registry_toggle,      as: :registry_toggle
  '      { :on => 'change',  :url => { :controller=>'gifts', 
                                  :action => 'registry_toggle', #'registry_toggle', 
                                  :user_id => @user, 
                                  :gift_id => @gift.id,
                                  :registry_id => registry.id },
=end

  #? map.connect ':controller/:action/:id'
  #? map.connect ':controller/:action/:id.:format'


end
