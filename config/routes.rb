Gemgento::Engine.routes.draw do
  root :to => "products#index"
  get '/error/:action', :controller => "errors"

  get '/addresses/region_options', to: 'addresses#region_options'

  match '/shop/:permalink' => 'products#show', via: :get, as: 'shop_permalink'
  get '/shop/product/:url_key', to: 'products#show'
  get '/shop/category/:url_key', to: 'categories#show'
  get '/shop/search', to: 'search#index'

  get '/checkout/shopping_bag', to: 'checkout#shopping_bag'
  get '/checkout/login', to: 'checkout#login'
  post '/checkout/login', to: 'checkout#login'
  post '/checkout/register', to: 'checkout#register'
  get '/checkout/address', to: 'checkout#address'
  get '/checkout/shipping', to: 'checkout#shipping'
  get '/checkout/payment', to: 'checkout#payment'
  get '/checkout/confirm', to: 'checkout#confirm'
  get '/checkout/thank_you', to: 'checkout#thank_you'
  post '/checkout/update', to: 'checkout#update'
  get '/order_export', to: 'order_export#index'

  get '/search', to: 'search#index'

  get '/sync/complete', to: 'sync#everything'
  get '/sync/products', to: 'sync#products'
  get '/sync/orders', to: 'sync#orders'

  devise_for :users, class_name: 'Gemgento::User',
             controllers: {:sessions => 'gemgento/users/sessions', :registrations => 'gemgento/users/registrations', :passwords => 'gemgento/users/passwords'},
             skip: [:unlocks, :omniauth_callbacks],
             module: :devise

  namespace 'users' do
    resources :orders, :addresses
  end

  resources :products, :categories, :orders, :checkout, :subscribers, :users

  patch '/orders', to: 'orders#update'

end