Gemgento::Engine.routes.draw do
  root :to => "products#index"
  resources :products
  match '/shop/:permalink' => 'products#show', via: :get, as: "shop_permalink"
end