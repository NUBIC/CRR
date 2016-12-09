FactoryGirl.define do
  factory :section do
    title Faker::Company.name
    association :survey
  end
end