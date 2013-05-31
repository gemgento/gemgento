Gemgento::Engine.routes.draw do
  root :to => "products#index"

  resources :products, :categories

  match '/shop/:permalink' => 'products#show', via: :get, as: 'shop_permalink'
  get '/shop/category/:url_key', to: 'categories#show'
end