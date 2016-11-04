FactoryGirl.define do
  factory :study_involvement_state do
  end

  factory :search_participant_study_involvement do |r|
    r.association :search_participant,  factory: :search_participant
    r.association :study_involvement,   factory: :study_involvement
  end

  factory :study_involvement_status do
    name  StudyInvolvementStatus.valid_statuses.map{|s| s[:name]}.sample
    association :study_involvement, factory: :study_involvement
  end

  sequence :irb_number do |n|
    "STU008888#{"%03d" % n}"
  end

  sequence :netid do |n|
    "tes#{"%03d" % n}"
  end

  factory :user do |u|
    u.netid {generate :netid}
  end

  factory :participant do |p|
    p.first_name { Faker::Name.first_name }
    p.last_name { Faker::Name.last_name }
  end

  factory :relationship do |r|
    r.category 'Child'
    r.association :origin, factory: :participant
    r.association :destination, factory: :participant
  end

  factory :study do |s|
    s.irb_number {generate :irb_number}
    s.name    {Faker::Company.name}
  end

  factory :study_involvement do |si|
    si.start_date Date.new(2013, 10, 5)
    si.end_date Date.new(2013, 10, 10)
    si.association :study, factory: :study
    si.association :participant, factory: :participant
  end

  factory :contact_log do |cl|
    cl.mode 'phone'
    cl.association :participant, factory: :participant
  end

  factory :search do |search|
    search.association :study, factory: :study
  end
  factory :search_condition_group do |scg|
    scg.association :search
    scg.association :search_condition_group
    scg.operator    ["|","&"].sample
  end

  factory :search_condition do |sc|
    sc.association :search_condition
    sc.operator   ["=","!=","<",">"].sample
  end

  factory :search_participant do |r|
    r.association :participant, factory: :participant
    r.association :search, factory: :search
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
    a.password "12345678"
    a.password_confirmation "12345678"
  end

  factory :account_participant do |ap|
    ap.association :account, factory: :account
    ap.association :participant, factory: :participant
  end

  factory :consent do |c|
    c.content "This is the test consent"
  end

  factory :consent_signature do |cs|
    cs.association :consent, factory: :consent
    cs.association :participant, factory: :participant
  end
end
