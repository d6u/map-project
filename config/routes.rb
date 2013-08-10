MapProject::Application.routes.draw do

  # root 'home#index'
  root 'home#index_async'
  get  'all_projects'        => 'home#index_async'
  get  'new_project'         => 'home#index_async'
  get  'project/:project_id' => 'home#index_async'


  scope '/users' do
    post 'login'    => 'users#login'
    get  'logout'   => 'users#logout'
  end
  resources :users


  scope '/projects/:project_id' do
    post 'add_participated_user' => 'projects#add_participated_user'
    get  'get_participated_user' => 'projects#get_participated_user'
  end
  resources :projects do
    resources :places
    resources :users
  end


  resources :friends
  resources :friendships


  post "invitation/generate"
  get  "invitation/join/:code" => 'invitation#join'
  post "invitation/join/:code" => 'invitation#joined'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
end
