FactoryGirl.define do
  factory :reminder do
    notification_text Faker::Lorem.paragraph
    deadline_text Faker::Lorem.paragraph
    name Faker::Commerce.product_name
    order 0
  end
end
