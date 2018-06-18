FactoryBot.define do
  factory :answer do
    text        { Faker::Company.name }
    association :question
  end
end
