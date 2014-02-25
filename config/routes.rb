Gemgento::Engine.routes.draw do
  root to: 'categories#index'

  if defined?(ActiveAdmin)
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self) if defined?(ActiveAdmin)
  end

  get '/error/:action', :controller => "errors"

  get '/addresses/region_options', to: 'addresses#region_options'

  match '/shop/:permalink' => 'products#show', via: :get, as: 'shop_permalink'
  get '/shop/product/:url_key', to: 'products#show'
  get '/shop/category/:url_key', to: 'categories#show'
  get '/shop/search', to: 'search#index'

  get '/order_export', to: 'order_export#index'

  get '/search', to: 'search#index'

  get '/sync/complete', to: 'sync#everything'
  get '/sync/products', to: 'sync#products'
  get '/sync/orders', to: 'sync#orders'
  get '/sync/busy', to: 'sync#busy'

  devise_for :users, class_name:  'Gemgento::User',
             controllers: {:sessions => 'gemgento/users/sessions', :registrations => 'gemgento/users/registrations', :passwords => 'gemgento/users/passwords'},
             skip: [:unlocks, :omniauth_callbacks],
             module: :devise

  # - Cart - #
  get '/checkout/shopping_bag', to: 'cart#show'
  get 'cart', to: 'cart#show'
  patch 'cart', to: 'cart#update'

  # - Checkout - #
  namespace :checkout do
    resource :login, only: [:show, :update], controller: 'gemgento/checkout/login'
    resource :gift, only: :update, controller: 'gemgento/checkout/gift'
    resource :address, only: [:show, :update], controller: 'gemgento/checkout/address'
    resource :shipping, only: [:show, :update], controller: 'gemgento/checkout/shipping'
    resource :payment, only: [:show, :update], controller: 'gemgento/checkout/payment'
    resource :confirm, only: [:show, :update], controller: 'gemgento/checkout/confirm'
    resource :thank_you, only: [:show], controller: 'gemgento/checkout/thank_you'
  end

  # - User Account Actions - #
  namespace :users do
    resources :orders, only: [:index, :show]
    resources :addresses, only: [:index, :show, :create, :destroy]
  end

  # - Magento Push Actions - #
  namespace :magento do
    resources :categories, only: :update
    resources :inventory, only: :update
    resources :orders, only: :update
    resources :products, only: [:update, :destroy]
    resources :product_attribute_sets, only: :update
    resources :product_attributes, only: :update
    resources :stores, only: :update
    resources :users, only: :update
  end

  # - Gemgento Resources - #
  resources :products, :categories, :orders, :subscribers, :users, :inventory, :product_attributes, :product_attribute_sets, :stores
  resources :countries, only: [:index, :show]

  patch '/orders', to: 'orders#update'
  put '/orders', to: 'orders#update'

end
