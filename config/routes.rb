Gemgento::Engine.routes.draw do
  root :to => "products#index"

  devise_for :users, class_name: 'Gemgento::User'

  get '/error/:action', :controller => "errors"

  namespace 'users' do
    resources :orders, :addresses
  end

  get '/addresses/region_options', to: 'addresses#region_options'

  match '/shop/:permalink' => 'products#show', via: :get, as: 'shop_permalink'
  get '/shop/product/:url_key', to: 'products#show'
  get '/shop/category/:url_key', to: 'categories#show'
  get '/shop/search', to: 'searches#index'

  get '/checkout/shopping_bag', to: 'checkout#shopping_bag'
  get '/checkout/login', to: 'checkout#login'
  post '/checkout/login', to: 'checkout#login'
  post '/checkout/register', to: 'checkout#register'
  get '/checkout/address', to: 'checkout#address'
  get '/checkout/shipping', to: 'checkout#shipping'
  get '/checkout/payment', to: 'checkout#payment'
  get '/checkout/confirm', to: 'checkout#confirm'
  get '/checkout/thank_you', to: 'checkout#thank_you'

  resources :products, :categories, :orders, :checkout

end