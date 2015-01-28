Gemgento::Engine.routes.draw do
  root to: 'home#index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get '/error/:action', :controller => "errors"

  get '/addresses/region_options', to: 'addresses#region_options'

  get '/order_export', to: 'order_export#index'

  # - Category - #
  get 'shop/:parent_url_key/:url_key',  to: 'categories#show', as: 'shop_by_parent_and_key'
  get 'shop/:url_key',                  to: 'categories#show', as: 'shop_by_key'
  get 'shop',                           to: 'categories#index', as: 'shop'

  # - SEARCH - #
  get '/search', to: 'search#index'
  get '/shop/search', to: 'search#index'


  # - SYNC - #
  get '/sync/complete', to: 'sync#everything'
  get '/sync/products', to: 'sync#products'
  get '/sync/orders', to: 'sync#orders'
  get '/sync/busy', to: 'sync#busy'

  devise_for :user, class_name: 'Gemgento::User',
             controllers: { sessions: 'gemgento/user/sessions', registrations: 'gemgento/user/registrations', passwords: 'gemgento/user/passwords' },
             skip: [:unlocks, :omniauth_callbacks],
             module: :devise

  # - Cart - #
  get '/cart', to: 'cart#show'
  post '/cart', to: 'cart#create', as: :cart_add_item
  patch '/cart', to: 'cart#create', as: :cart_add_item_patch
  resources :cart, only: :update, as: :cart_update_item
  resources :cart, only: :destroy, as: :cart_remove_item
  get '/cart/mini-bag', to: 'cart#mini_bag'

  # - Checkout - #
  namespace :checkout do

    # login actions
    resource :login, only: :show, controller: 'login'
    post '/guest', to: 'login#guest'
    post '/login', to: 'login#login', as: :sign_in
    post '/registration', to: 'login#register'
    get '/guest', to: 'login#show'
    get '/registration', to: 'login#show'

    resource :gift, only: :update, controller: 'gift'
    resource 'gift-card', only: [:create, :destroy], controller: 'gift_card', as: :gift_card
    resource :coupons, only: [:create, :destroy], controller: 'coupons'
    resource :address, only: [:show, :update], controller: 'address'
    resource :shipping, only: [:show, :update], controller: 'shipping'
    resource :payment, only: [:show, :update], controller: 'payment'
    resource :shipping_payment, only: [:show, :update], controller: 'shipping_payment'
    resource :confirm, only: [:show, :update], controller: 'confirm'
    resource :thank_you, only: [:show], controller: 'thank_you'
  end

  # - User Account Actions - #
  namespace :user do
    resources :addresses
    resources :orders, only: [:index, :show]
    resources :recurring_profiles, only: [:index, :destroy]
    resources :saved_credit_cards, only: [:index, :new, :create, :destroy]
    resources :wishlist_items, only: [:index, :create, :destroy]

    get '', to: 'home#index', as: 'home'

    # combined login / sign up controller
    get 'login', to: 'registration_session#new', as: 'new_login'
    post 'login', to: 'registration_session#create', as: 'login'
  end

  # - Magento Push Actions - #
  namespace :magento do
    resources :addresses, only: [:update, :destroy]
    resources :categories, only: [:update, :destroy]
    resources :inventory, only: :update
    resources :orders, only: :update
    resources :products, only: [:update, :destroy]
    resources :price_rules, only: [:update, :destroy]
    resources :product_attribute_sets, only: [:update, :destroy]
    resources :product_attributes, only: [:update, :destroy]
    resources :recurring_profiles, only: :update
    resources :stores, only: :update
    resources :users, only: [:update, :destroy]
    resources :user_groups, only: [:update, :destroy]
  end

  # - Gemgento Resources - #
  resources :products, only: [:index, :show]
  resources :categories, :orders, :subscribers
  resources :countries, :regions, only: [:index, :show]
  resource :search, only: [:show], controller: 'gemgento/search'
  resources :stock_notifications, only: :create

  patch '/orders', to: 'orders#update'
  put '/orders', to: 'orders#update'

  get '/gemgento/about',          to: 'pages#about'
  get '/gemgento/contact',        to: 'pages#contact'
  get '/gemgento/terms-of-use',   to: 'pages#terms_of_use', as: 'terms_of_use'
  get '/gemgento/return-policy',  to: 'pages#return_policy', as: 'return_policy'
end
