FactoryGirl.define do
  factory :search_condition do
    association :search_condition
    operator   ["=","!=","<",">"].sample
  end
end