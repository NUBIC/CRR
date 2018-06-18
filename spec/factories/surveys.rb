FactoryBot.define do
  factory :survey do
    title             { Faker::Company.name }
    multiple_section  true
  end
end
