FactoryGirl.define do
  factory :participant do |p|
    p.first_name "Brian"
    p.last_name "Lee"
  end

  factory :relationship do |r|
    r.category 'sibling'
    r.association :origin, :factory => :participant
    r.association :destination, :factory => :participant
  end

  factory :study do |s|
    s.active_on Date.new(2013, 10, 3)
  end

  factory :study_involvement do |r|
    r.start_date Date.new(2013, 10, 5)
    r.association :study, :factory => :study
    r.association :participant, :factory => :participant
  end
end