FactoryGirl.define do
  factory :account do
    email                 "test@test.com"
    password              "12345678"
    password_confirmation "12345678"
  end
end