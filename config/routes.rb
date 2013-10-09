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
      get  'login_status' => 'auth#login_status'
      post 'fb_register'  => 'auth#fb_register'
      post 'fb_login'     => 'auth#fb_login'
    end

    # --- User ---
    scope '/users' do
      post 'email_login'    => 'users#email_login'
      post 'email_register' => 'users#email_register'
      get  'logout'         => 'users#logout'
    end
    resources :users, :only => [:index, :update]

    # --- Project ---
    resources :projects, :only => [:index, :create, :show, :update, :destroy] do
      resources :places, :only => [:index, :create, :show, :update, :destroy]
      get    'participating_users' => 'projects#participating_users'
      post   'add_users'           => 'projects#add_users'
      delete 'remove_users'        => 'projects#remove_users'
    end


    resources :friends,       :only => [:index, :show]

    resources :friendships,   :only => [:index, :create, :show, :update, :destroy]

    resources :notifications, :only => [:index, :destroy]
    scope    '/notifications/:id' do
      post   'accept_friend_request' => 'notifications#accept_friend_request'
      delete 'ignore_friend_request' => 'notifications#ignore_friend_request'
      post   'accept_project_invitation' => 'notifications#accept_project_invitation'
      delete 'reject_project_invitation' => 'notifications#reject_project_invitation'
    end

    scope     'invitations/:code' do
      get     'accept_invitation' => 'invitations#accept_invitation'
    end
    resources :invitations, :only => [:index, :create, :destroy]

  end

  # invitations
  get '/invitations/:code' => 'invitations#show'

end
