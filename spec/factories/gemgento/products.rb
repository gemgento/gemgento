FactoryGirl.define do
  factory :gemgento_product, class: 'Gemgento::Product'  do
    sku { Faker::Code.isbn }
    association :product_attribute_set, factory: :gemgento_product_attribute_set
    sync_needed false
    status true

    after(:create) do |product|
      store = Gemgento::Store.find_or_initialize_by(magento_id: 1)
      store.update!(code: 'Default', name: 'Default Store View')
      product.stores << store
    end

    factory :gemgento_product_with_attributes do
      association :product_attribute_set, factory: :gemgento_product_attribute_set_with_attributes

      after(:create) do |product|
        product.set_attribute_value('price', 100.0)
      end
    end

  end
end