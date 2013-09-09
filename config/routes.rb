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

    scope '/users' do
      post 'login'    => 'users#login'
      get  'logout'   => 'users#logout'
      post 'register' => 'users#create'
    end
    resources :users, :only => [:index, :update]


    resources :projects, :only => [:index, :create, :show, :update, :destroy] do
      resources :places, :only => [:index, :create, :show, :update, :destroy]
      resources :users,  :only => [:index]
    end
    scope '/projects/:project_id' do
      post   'add_user'  => 'projects#add_user'
      delete 'users/:id' => 'projects#remove_user'
    end

    resources :friends,       :only => [:index, :show]

    resources :friendships,   :only => [:index, :create, :show, :update, :destroy]
    scope    '/friendships/:id' do
      post   'accept_friend_request' => 'friendships#accept_friend_request'
    end

    resources :notifications, :only => [:index, :destroy]
    scope    '/notifications/:id' do
      delete 'ignore_friend_request' => 'notifications#ignore_friend_request'
    end

  end

end
