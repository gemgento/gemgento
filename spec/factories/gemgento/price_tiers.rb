FactoryGirl.define do
  factory :gemgento_price_tier, class: 'Gemgento::PriceTier'  do
    association :product, factory: :gemgento_product
    association :store, factory: :gemgento_store
    quantity 10
    price 10
  end
end