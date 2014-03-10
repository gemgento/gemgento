Gemgento::Engine.routes.draw do
  root to: 'categories#index'

  if defined?(ActiveAdmin)
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self) if defined?(ActiveAdmin)
  end

  get '/error/:action', :controller => "errors"

  get '/addresses/region_options', to: 'addresses#region_options'

  get '/order_export', to: 'order_export#index'

  get '/shop', to: 'categories#index', as: 'categories'
  get '/shop/search', to: 'search#index'
  get '/search', to: 'search#index'

  get '/sync/complete', to: 'sync#everything'
  get '/sync/products', to: 'sync#products'
  get '/sync/orders', to: 'sync#orders'
  get '/sync/busy', to: 'sync#busy'

  devise_for :users, class_name: 'Gemgento::User',
             controllers: {:sessions => 'gemgento/users/sessions', :registrations => 'gemgento/users/registrations', :passwords => 'gemgento/users/passwords'},
             skip: [:unlocks, :omniauth_callbacks],
             module: :devise

  # - Cart - #
  get '/checkout/shopping_bag', to: 'cart#show'
  get 'cart', to: 'cart#show'
  patch 'cart', to: 'cart#update'

  # - Checkout - #
  namespace :checkout do
    resource :login, only: [:show, :update], controller: 'login'
    resource :gift, only: :update, controller: 'gift'
    resource :address, only: [:show, :update], controller: 'address'
    resource :shipping, only: [:show, :update], controller: 'shipping'
    resource :payment, only: [:show, :update], controller: 'payment'
    resource :confirm, only: [:show, :update], controller: 'confirm'
    resource :thank_you, only: [:show], controller: 'thank_you'
  end

  # - User Account Actions - #
  namespace :users do
    resources :orders, only: [:index, :show]
    resources :addresses, only: [:index, :show, :create, :destroy]
  end

  # - Magento Push Actions - #
  namespace :magento do
    resources :categories, only: [:update, :destroy]
    resources :inventory, only: :update
    resources :orders, only: :update
    resources :products, only: [:update, :destroy]
    resources :product_attribute_sets, only: [:update, :destroy]
    resources :product_attributes, only: [:update, :destroy]
    resources :stores, only: :update
    resources :users, only: [:update, :destroy]
  end

  # - Gemgento Resources - #
  resources :products, :categories, :orders, :subscribers, :users
  resources :countries, only: [:index, :show]
  resource :search, only: [:show], controller: 'gemgento/search'

  patch '/orders', to: 'orders#update'
  put '/orders', to: 'orders#update'

end
