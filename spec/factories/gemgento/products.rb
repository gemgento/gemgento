FactoryGirl.define do
  factory :gemgento_product, class: 'Gemgento::Product'  do
    magento_type 'simple'
    sku { Faker::Code.isbn }
    association :product_attribute_set, factory: :gemgento_product_attribute_set
    sync_needed false
    status true
    visibility 4
  end

end