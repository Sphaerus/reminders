FactoryGirl.define do
  factory :project_check do
    reminder_id nil
    project_id nil
    info Faker::Lorem.sentence
  end
end
