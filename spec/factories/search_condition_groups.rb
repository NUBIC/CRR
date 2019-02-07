FactoryBot.define do
  factory :search_condition_group do
    association :search
    association :search_condition_group
    operator    { ["|","&"].sample }
  end
end
