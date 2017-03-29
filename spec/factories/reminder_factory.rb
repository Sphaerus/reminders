FactoryGirl.define do
  factory :reminder do
    notification_text Faker::Lorem.paragraph
    deadline_text Faker::Lorem.paragraph
    name Faker::Commerce.product_name
    init_valid_for_n_days 30
  end
end
