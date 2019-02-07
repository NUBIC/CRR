FactoryBot.define do
  factory :account do
    email                 { Faker::Internet.email }
    password              { "12345678" }
    password_confirmation { "12345678" }
  end
end
