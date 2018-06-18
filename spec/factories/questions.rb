FactoryBot.define do
  factory :question do
    text        { Faker::Company.name }
    association :section
  end
end
