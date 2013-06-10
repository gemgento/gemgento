Gemgento::Engine.routes.draw do
  root :to => "products#index"

  resources :products, :categories, :users, :orders

  namespace 'user' do
    resources :orders
  end

  match '/shop/:permalink' => 'products#show', via: :get, as: 'shop_permalink'
  get '/shop/product/:url_key', to: 'products#show'
  get '/shop/category/:url_key', to: 'categories#show'
  get '/shop/search', to: 'searches#index'

end