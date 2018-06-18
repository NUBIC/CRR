FactoryBot.define do
  factory :study_involvement do
    start_date    Date.new(2013, 10, 5)
    end_date      Date.new(2013, 10, 10)
    association   :study, factory: :study
    association   :participant, factory: :participant
  end
end