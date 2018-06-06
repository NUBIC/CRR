FactoryBot.define do
  factory :account_participant do
    association :account, factory: :account
    association :participant, factory: :participant
  end
end