FactoryBot.define do
  factory :search do
    association :study, factory: :study
  end

  factory :submitted_request, class: 'Search' do
    association   :study, factory: :study
    state         'data_requested'
    request_date  Date.today
  end

  factory :released_request, class: 'Search' do
    association   :study, factory: :study
    state         'data_released'
    request_date  Date.today - 2.days
    process_date  Date.today - 1.days
    start_date    Date.today
    warning_date  Date.today + 1.day
    end_date      Date.today + 2.days
  end

  factory :expiring_request, class: 'Search' do
    association   :study, factory: :study
    state         'data_released'
    request_date  Date.today - 3.day
    process_date  Date.today - 2.day
    start_date    Date.today - 1.day
    warning_date  Date.today
    end_date      Date.today + 2.days
  end

  factory :expired_request, class: 'Search' do
    association   :study, factory: :study
    state         'data_released'
    request_date  Date.today - 5.days
    process_date  Date.today - 4.days
    start_date    Date.today - 3.days
    warning_date  Date.today - 2.days
    end_date      Date.today - 1.day
  end
end