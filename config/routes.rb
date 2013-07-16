Gemgento::Engine.routes.draw do
  root :to => "products#index"

  resources :products, :categories, :users, :orders, :addresses
  get '/error/:action', :controller => "errors"

  namespace 'user' do
    resources :orders, :addresses
  end

  match '/shop/:permalink' => 'products#show', via: :get, as: 'shop_permalink'
  get '/shop/product/:url_key',       to: 'products#show'
  get '/shop/category/:url_key',      to: 'categories#show'
  get '/shop/search',                 to: 'searches#index'

  get '/checkout/shopping_bag',       to: 'checkout#shopping_bag'
  get '/checkout/login',              to: 'checkout#login'
  get '/checkout/address',            to: 'checkout#address'
  get '/checkout/shipping',           to: 'checkout#shipping'
  get '/checkout/payment',            to: 'checkout#payment'
  get '/checkout/confirm',            to: 'checkout#confirm'

end