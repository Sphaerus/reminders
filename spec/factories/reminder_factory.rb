FactoryGirl.define do
  factory :reminder do
    init_valid_for_n_days Faker::Number.number(1)
    init_notification_text Faker::Lorem.paragraph
    notification_text Faker::Lorem.paragraph
    init_deadline_text Faker::Lorem.paragraph
    deadline_text Faker::Lorem.paragraph
    name Faker::Commerce.product_name
  end
end
