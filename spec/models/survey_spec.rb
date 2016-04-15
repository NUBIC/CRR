require 'spec_helper'

describe Survey do
  it 'should create section for surveys that are not multiple sections' do
    survey = FactoryGirl.create(:survey, multiple_section: false)
    expect(survey.sections.size).to eq 1
  end
end
