FactoryGirl.define do
  factory :gemgento_product_attribute_set, class: 'Gemgento::ProductAttributeSet'  do
    name 'default attribute set'

    factory :gemgento_product_attribute_set_with_attributes do
      after(:create) do |attribute_set|
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'price', frontend_input: 'price')
      end
    end

  end
end