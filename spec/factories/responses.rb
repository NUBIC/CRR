FactoryGirl.define do
  factory :response do
    association :response_set
    association :question
    association :answer
  end
end