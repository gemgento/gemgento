Gemgento::Engine.routes.draw do
  root :to => 'products#index'

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

  get '/checkout/shopping_bag', to: 'cart#show'

  namespace 'checkout' do
    get 'login', to: 'login#show', as: 'login'
    post 'login', to: 'login#update', as: 'login_update'

    get 'address', to: 'address#show', as: 'address'
    post 'address', to: 'address#update', as: 'address_update'

    get 'shipping', to: 'shipping#show', as: 'shipping'
    post 'shipping', to: 'shipping#update', as: 'shipping_update'

    get 'payment', to: 'payment#show', as: 'payment'
    post 'payment', to: 'payment#update', as: 'payment_update'

    get 'confirmation', to: 'confirmation#show', as: 'confirmation'

    get 'thank_you', to: 'thank_you#show', as: 'thank_you'
  end

  namespace 'users' do
    resources :orders, :addresses
  end

  resources :products, :categories, :orders, :checkout, :subscribers, :users

  patch '/orders', to: 'orders#update'

end