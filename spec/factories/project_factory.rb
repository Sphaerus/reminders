FactoryGirl.define do
  factory :project do
    name { Faker::Commerce.product_name }
    email { Faker::Internet.email }
    channel_name { Faker::Lorem.word }
    pm_slack_name { Faker::Lorem.word }
  end
end
