Rails.application.routes.draw do
  root to: redirect('/welcome')

  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  get 'settings', to: 'settings#index', as: 'settings'
  post 'users/reset_username', to: 'settings#update_username', as: 'update_username'
  post 'users/reset_password', to: 'settings#update_password', as: 'update_password'

  get 'admin', to: 'admin#index', as: 'admin'
  get 'admin/edit_user/:id', to: 'admin#edit_user', as: 'edit_user'
  post 'admin/edit_user/:id', to: 'admin#edit_user_form', as: 'edit_user_form'
  get 'admin/add_user', to: 'admin#add_user', as: 'add_user'
  post 'admin/add_user', to: 'admin#add_user_form', as: 'add_user_form'
  delete 'admin/delete_user', to: 'admin#delete_user_form', as: 'delete_user_form'

  get 'register', to: 'registrations#new', as: 'register'
  post 'register', to: 'registrations#create'
  resources :password_resets, only: [:new, :create, :edit, :update]

  get 'welcome', to: 'welcome#index', as: 'welcome'

  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  get 'shop', to: 'shop#index', as: 'shop'
  get 'shop/balance', to: 'shop#balance', as: 'shop_balance'
  post 'shop/purchase', to: 'shop#purchase', as: 'shop_purchase'
  post 'shop/payment', to: 'shop#payment', as: 'shop_payment'
  get 'shop/payment_history', to: 'shop#payment_history', as: 'shop_payment_history'

  get 'tiles', to: 'tiles#get_tile', as: 'get_tile'
  get 'tiles/get_tile', to: 'tiles#get_tile'
  get 'tiles/get_image', to: 'tiles#get_image'

  post 'tiles/fight_monster', to: 'tiles#fight_monster'
  post 'tiles/loot_tile', to: 'tiles#loot_tile'
  post 'tiles/regenerate', to: 'tiles#regenerate_tile'
  post 'tiles/teleport', to: 'tiles#teleport_tile'



  delete 'items/:id', to: 'games#destroy', as: 'destroy_item'

  get '/gameshop', to: 'gameshop#index', as: 'gameshop'
  post '/gameshop/buy', to: 'gameshop#buy', as: 'gameshop_buy'
  get '/gameshop/generate_items', to: 'gameshop#generate_items', as: 'generate_gameshop_items'
  post '/gameshop/update_shards', to: 'gameshop#update_shards', as: 'update_gameshop_shards'


  get 'characters', to: 'characters#get_characters', as: 'characters'
  post 'move_character', to: 'characters#move_character', as: 'move_character'

  get '/auth/:provider/callback', to: 'sessions#auth_success', as: 'auth_success'
  get '/auth/failure', to: 'sessions#auth_failure', as: 'auth_failure'

  get 'characters/items', to: 'characters#items', as: 'character_items'

  post 'chat', to: 'chat#create', as: 'chat_send'
  get 'chat', to: 'chat#list', as: 'chat_list'

  resources :games do
    get 'list', on: :collection
    post 'add', on: :member
    #post 'move_character', on: :member
    #resources :tiles
    # We can also add the resources :characters here if we decide we need a controller for it. It will allow us to
    # ensure that the game session the character or tile is attached to is always knowable.
  end
end
