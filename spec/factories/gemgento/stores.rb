FactoryGirl.define do
  factory :gemgento_store, class: 'Gemgento::Store' do
    magento_id 1
    code 'default'
    currency_code 'usd'
    is_active true
    name 'Default Store'
    initialize_with { Gemgento::Store.find_or_create_by!(magento_id: magento_id) }
  end

end