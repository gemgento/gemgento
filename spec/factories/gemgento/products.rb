FactoryGirl.define do
  factory :gemgento_product, class: 'Gemgento::Product'  do
    sku { Faker::Code.isbn }
    association :product_attribute_set, factory: :gemgento_product_attribute_set
    sync_needed false
    status true
    stores {[FactoryGirl.create(:gemgento_store)]}

    factory :gemgento_product_with_attributes do
      association :product_attribute_set, factory: :gemgento_product_attribute_set_with_attributes
    end

  end
end