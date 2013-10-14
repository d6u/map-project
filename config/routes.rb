MapProject::Application.routes.draw do


  root 'home#index'


  get  'dashboard'           => 'home#index'
  get  'project/:project_id' => 'home#index'
  get  'friends'             => 'home#index'
  get  'search'              => 'home#index'
  get  'settings'            => 'home#index'


  get  'mobile'                     => 'home#mobile_index'
  get  'mobile/dashboard'           => 'home#mobile_index'
  get  'mobile/project/:project_id' => 'home#mobile_index'


  # JSON API point
  namespace :api do

    # --- Auth ---
    scope '/auth' do
      get  'login_status'      => 'auth#login_status'
      post 'fb_register'       => 'auth#fb_register'
      post 'fb_login'          => 'auth#fb_login'
      post 'fb_remember_login' => 'auth#fb_remember_login'
      post 'email_login'       => 'auth#email_login'
      post 'email_register'    => 'auth#email_register'
      get  'logout'            => 'auth#logout'
    end

    # --- User ---
    resources :users, :only => [:index, :update]

    # --- Project ---
    resources :projects, :only => [:index, :create, :show, :update, :destroy] do
      resources :places, :only => [:index, :create, :show, :update, :destroy]
      resources :chat_histories, :only => [:index, :create, :show]
      get    'participating_users' => 'projects#participating_users'
      post   'add_users'           => 'projects#add_users'
      delete 'remove_users'        => 'projects#remove_users'
    end

    # --- Friendships ---
    resources :friendships, :only => [:index, :create, :show, :update, :destroy]

    resources :notices, :only => [:index, :destroy]
    scope    '/notices/:id' do
      post   'accept_friend_request'     => 'notices#accept_friend_request'
      delete 'ignore_friend_request'     => 'notices#ignore_friend_request'
      post   'accept_project_invitation' => 'notices#accept_project_invitation'
      delete 'reject_project_invitation' => 'notices#reject_project_invitation'
    end

    scope     'invitations/:code' do
      get     'accept_invitation' => 'invitations#accept_invitation'
    end
    resources :invitations, :only => [:index, :create, :destroy]

  end

  # invitations
  get '/invitations/:code' => 'invitations#show'


  # --- Development Routes ---
  if !Rails.env.production?
    get '/scripts/*template_path.html' => 'ng_templates#index'
  end

end
