FactoryGirl.define do
  factory :consent_signature do
    association :consent, factory: :consent
    association :participant, factory: :participant
  end
end
