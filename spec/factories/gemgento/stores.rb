FactoryGirl.define do
  factory :gemgento_store, class: 'Gemgento::Store' do
    code 'default'
    currency_code 'usd'
    is_active true
    name 'Default Store'
    magento_id 1
  end

end