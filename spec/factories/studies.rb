FactoryBot.define do
  sequence :irb_number do |n|
    "STU008888#{"%03d" % n}"
  end

  factory :study do
    irb_number { generate :irb_number }
    name       { Faker::Company.name }
  end
end