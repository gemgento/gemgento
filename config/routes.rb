Gemgento::Engine.routes.draw do
  root :to => 'categories#index'

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

  devise_for :users, class_name: 'Gemgento::User',
             controllers: {:sessions => 'gemgento/users/sessions', :registrations => 'gemgento/users/registrations', :passwords => 'gemgento/users/passwords'},
             skip: [:unlocks, :omniauth_callbacks],
             module: :devise

  # - Cart - #
  get '/checkout/shopping_bag', to: 'cart#show'
  get 'cart', to: 'cart#show'
  patch 'cart', to: 'cart#update'

  # - Checkout - #
  namespace 'checkout' do
    get 'login', to: 'login#show', as: 'login'
    put 'login', to: 'login#update', as: 'login_update'

    get 'address', to: 'address#show', as: 'address'
    patch 'address', to: 'address#update', as: 'address_update'

    get 'shipping', to: 'shipping#show', as: 'shipping'
    patch 'shipping', to: 'shipping#update', as: 'shipping_update'

    get 'payment', to: 'payment#show', as: 'payment'
    patch 'payment', to: 'payment#update', as: 'payment_update'

    get 'confirm', to: 'confirm#show', as: 'confirm'
    patch 'confirm', to: 'confirm#update', as: 'confirm_update'

    get 'thank_you', to: 'thank_you#show', as: 'thank_you'
  end

  namespace 'users' do
    resources :orders, :addresses
  end

  resources :products, :categories, :orders, :subscribers, :users, :inventory, :product_attributes, :product_attribute_sets, :stores
  resources :countries, only: [:index, :show]

  patch '/orders', to: 'orders#update'
  put '/orders', to: 'orders#update'

end
