FactoryGirl.define do
  factory :search_participant do
    association :participant, factory: :participant
    association :search, factory: :search
  end
end