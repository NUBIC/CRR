FactoryBot.define do
  factory :contact_log do
    mode { 'phone' }
    association :participant, factory: :participant
  end
end
