FactoryGirl.define do
  factory :project do
    name { Faker::Lorem.word }
    email { Faker::Internet.email }
    channel_name { Faker::Lorem.word }
  end
end
