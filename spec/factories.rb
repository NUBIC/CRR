FactoryGirl.define do


  sequence :irb_number do |n|
    "STU008888#{"%03d" % n}"
  end

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
    s.irb_number {generate :irb_number}
    s.name    {Faker::Company.name}
  end

  factory :study_involvement do |si|
    si.start_date Date.new(2013, 10, 5)
    si.association :study, :factory => :study
    si.association :participant, :factory => :participant
  end

  factory :contact_log do |cl|
    cl.mode 'phone'
    cl.association :participant, :factory => :participant
  end

  factory :search do |search|
    search.association :study, :factory => :study
  end

  factory :survey do |s|
    s.title Faker::Company.name
    s.multiple_section true
  end
  factory :section do |s|
    s.title Faker::Company.name
    s.association :survey
  end
  factory :question do |q|
    q.association :section
  end
  factory :answer do |q|
    q.association :question
  end
  factory :response_set do |r|
    r.association :participant
  end
  factory :response do |r| 
    r.association :response_set
    r.association :question
    r.association :answer
  end

  factory :account do |a|
    a.email "test@test.com"
    a.password "1234"
    a.password_confirmation "1234"
  end

  factory :consent do |c|
    c.content "This is the test consent"
  end

  factory :consent_signature do |cs|
    cs.association :consent, :factory => :consent
    cs.association :participant, :factory => :participant
  end
end
