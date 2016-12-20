FactoryGirl.define do
  factory :answer do
    association :question
  end
end