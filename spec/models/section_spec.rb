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

  it 'removes trailing spaces from title' do
    survey = FactoryGirl.create(:survey, multiple_section: true)
    section = survey.sections.create(title: '  test  ')
    expect(section.title).to eq 'test'

    section.title = '  test1  '
    section.save
    expect(section.title).to eq 'test1'
  end
end
