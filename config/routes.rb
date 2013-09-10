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
  scope '/api' do

    # --- User ---
    scope '/users' do
      post 'login'    => 'users#login'
      get  'logout'   => 'users#logout'
      post 'register' => 'users#create'
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
    end

  end

end
