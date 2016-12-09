FactoryGirl.define do
  factory :study_involvement_status do
    name        StudyInvolvementStatus.valid_statuses.map{|s| s[:name]}.sample
    association :study_involvement, factory: :study_involvement
  end
end