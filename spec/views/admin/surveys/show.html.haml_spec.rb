require 'spec_helper'
describe 'admin/surveys/show.html.haml' do

  before(:each) do
    @survey = FactoryGirl.create(:survey, multiple_section: true)
    @section = @survey.sections.create(title: 'section 1')
    @question = @section.questions.create(text: 'question 1', response_type: 'pick_one')
    @answer = @question.answers.create(text:'answer 1')
    @answer2 = @question.answers.create(text:'answer 2')
    allow(view).to receive(:policy).and_return(double("some policy", destroy?: true))
    login_user
  end

  describe 'active survey' do
    before(:each) do
      @survey.state='active'
      @survey.save
      @survey.reload
      expect(@survey.state).to eq('active')
    end

    it 'not provide ability to add sections or edit' do
      assign(:survey,@survey)
      render
      expect(rendered).not_to  match /Edit/
      expect(rendered).not_to  match /Add Section/
    end

    it 'should provide ability to deactivate survey' do
      assign(:survey, @survey)
      render
      expect(rendered).to  match /Deactivate/
    end
  end

  describe 'inactive survey' do
    it 'should show add section and edit buttons' do
      assign(:survey, @survey)
      render
      expect(rendered).to  match /Edit/
      expect(rendered).to  match /Add Section/
    end

    it 'should not show add section button for single section survey' do
      @survey.update_attributes(:multiple_section=>false)
      @survey.reload
      assign(:survey, @survey)
      render
      expect(rendered).not_to  match /Add Section/
    end
  end
end
