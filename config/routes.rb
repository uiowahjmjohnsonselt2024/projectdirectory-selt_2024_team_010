Rails.application.routes.draw do
  root to: redirect('/welcome')

  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  get 'settings', to: 'settings#index', as: 'settings'
  post 'users/reset_username', to: 'settings#update_username', as: 'update_username'
  post 'users/reset_password', to: 'settings#update_password', as: 'update_password'

  get 'register', to: 'registrations#new', as: 'register'
  post 'register', to: 'registrations#create'

  get 'welcome', to: 'welcome#index', as: 'welcome'

  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  get 'shop', to: 'shop#index', as: 'shop'
  get 'shop/balance', to: 'shop#balance', as: 'shop_balance'
  post 'shop/purchase', to: 'shop#purchase', as: 'shop_purchase'
  post 'shop/payment', to: 'shop#payment', as: 'shop_payment'
  get 'shop/payment_history', to: 'shop#payment_history', as: 'shop_payment_history'

  get 'tiles', to: 'tiles#get_tile', as: 'get_tile'
  get 'tiles/get_tile', to: 'tiles#get_tile'


  resources :games do
    get 'list', on: :collection
    post 'add', on: :member
    #resources :tiles
    # We can also add the resources :characters here if we decide we need a controller for it. It will allow us to
    # ensure that the game session the character or tile is attached to is always knowable.
  end
end
