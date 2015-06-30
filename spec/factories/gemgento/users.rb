FactoryGirl.define do
  factory :gemgento_user, class: 'Gemgento::User'  do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password 'Password123'
    sync_needed false
    association :user_group, factory: :gemgento_user_group

    after(:build) { |user| user.class.skip_callback(:create, :before, :magento_create) }
  end

end