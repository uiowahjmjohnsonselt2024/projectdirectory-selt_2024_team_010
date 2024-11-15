Rails.application.routes.draw do
  root to: redirect('/welcome')

  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create', as: 'login_create'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  get 'register', to: 'registrations#new', as: 'register'
  post 'register', to: 'registrations#create'

  get 'welcome', to: 'welcome#index', as: 'welcome'

  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  get 'servers', to: 'servers#index', as: 'servers'

  get 'shop', to: 'shop#index', as: 'shop'

  get 'game', to: 'game#index', as: 'game'
end
