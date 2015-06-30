FactoryGirl.define do
  factory :gemgento_store, class: 'Gemgento::Store' do
    id 1
    magento_id 1
    code 'default'
    currency_code 'usd'
    is_active true
    name 'Default Store'
    initialize_with { Gemgento::Store.find_or_initialize_by(id: id) }
  end

end