MapProject::Application.routes.draw do


  root                               'home#index'
  get  'home'                     => 'home#index'
  get  'home/project/:project_id' => 'home#index'


  get  'mobile'                          => 'home#mobile_index'
  get  'mobile/home'                     => 'home#mobile_index'
  get  'mobile/home/project/:project_id' => 'home#mobile_index'


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
    post   'users'     => 'projects#add_user'
    delete 'users/:id' => 'projects#remove_user'
  end


  resources :friends,       :only => [:index, :show]
  resources :friendships,   :only => [:index, :create, :show, :update, :destroy]
  resources :notifications, :only => [:index]


  post "invitation/generate"
  get  "invitation/join/:code" => 'invitation#join'
  post "invitation/join/:code" => 'invitation#joined'

end
