require 'rails_helper'

RSpec.describe Survey, type: :model do
  it 'should create section for surveys that are not multiple sections' do
    survey = FactoryBot.create(:survey, multiple_section: false)
    expect(survey.sections.size).to eq 1
  end
end
