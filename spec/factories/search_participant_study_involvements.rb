FactoryGirl.define do
  factory :search_participant_study_involvement do
    association :search_participant,  factory: :search_participant
    association :study_involvement,   factory: :study_involvement
  end
end