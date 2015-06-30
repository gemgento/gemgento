FactoryGirl.define do
  factory :gemgento_product_attribute_set, class: 'Gemgento::ProductAttributeSet'  do
    name 'default attribute set'

    factory :gemgento_product_attribute_set_with_attributes do
      after(:create) do |attribute_set|
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'price', frontend_input: 'price')

        # giftvoucher attributes
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'gift_price_type', frontend_input: 'text')
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'gift_price', frontend_input: 'price')
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'gift_value', frontend_input: 'price')

        # special price attributes
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'special_price', frontend_input: 'price')
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'special_from_date', frontend_input: 'price')
        attribute_set.product_attributes << Gemgento::ProductAttribute.new(code: 'special_to_date', frontend_input: 'price')
      end
    end

  end
end