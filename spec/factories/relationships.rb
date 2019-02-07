FactoryBot.define do
  factory :relationship do |r|
    r.category { 'Child' }
    r.association :origin, factory: :participant
    r.association :destination, factory: :participant
  end
end
