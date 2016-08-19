require 'rails_helper'

RSpec.describe Section, type: :model do
  it 'should not allow more than one section where multiple section is false' do
    survey = FactoryGirl.create(:survey, multiple_section: false)
    expect(survey.sections.size).to eq 1

    survey.reload
    section = survey.sections.create(title: 'test')
    survey.reload
    expect(survey.sections.size).to eq 1
    expect(section).not_to be_valid
    expect(section.errors[:survey_id].size).to be >= 1
  end
end
