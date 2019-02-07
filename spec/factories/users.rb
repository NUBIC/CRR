FactoryBot.define do
  sequence :netid do |n|
    "tes#{"%03d" % n}"
  end

  factory :user do
    netid { generate :netid }
  end
end
