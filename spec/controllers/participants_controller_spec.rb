require 'spec_helper'

describe ParticipantsController do
  setup :activate_authlogic
  let(:account) { FactoryGirl.create(:account) }
  let(:participant) { FactoryGirl.create(:participant) }

  before(:each) do
    @adult_survey = setup_survey('adult')
    @child_survey = setup_survey('child')
  end

  describe '#index' do
    before(:each) do
      @account_participant = FactoryGirl.create(:account_participant, account: account, participant: participant, proxy: true)
    end
    it 'returns the participant' do
      get :enroll, id: participant.id
      expect(flash['error']).to be_nil
    end

    it 'create and redirects to the edit_response_set of adult_survey if participant state is "survey" and is adult participant' do
      participant.stage = 'survey'
      participant.save
      get :enroll, id: participant.id
      expect(participant.response_sets.size).to eq 1
      expect(response).to redirect_to(controller: :response_sets, action: :edit, id: participant.recent_response_set.id)
      expect(participant.recent_response_set.survey).to eq @adult_survey
    end

    it 'create and redirects to the edit_response_set of child_survey if participant state is "survey" and is child participant' do
      participant.stage = 'survey'
      participant.child = true
      participant.save
      get :enroll, id: participant.id
      expect(participant.response_sets.size).to eq 1
      expect(response).to redirect_to(controller: :response_sets, action: :edit, id: participant.recent_response_set.id)
      expect(participant.recent_response_set.survey).to eq @child_survey
    end

    describe 'unauthorized access' do
      before(:each) do
        AccountSession.create(FactoryGirl.create(:account, email: 'other@test.con'))
        get :enroll, id: participant.id
      end

      it 'redirect_to to the logout page' do
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        expect(flash['error']).to eq 'Access Denied'
      end
    end
  end

  describe '#consent' do
    before(:each) do
      @account_participant = FactoryGirl.create(:account_participant, account: account, participant: participant, proxy: true)
    end

    it 'return the participant for consent view' do
      get :enroll, id: participant.id
      expect(flash['error']).to be_nil
    end

    describe 'unauthorized access' do
      before(:each) do
        AccountSession.create(FactoryGirl.create(:account, email: 'other@test.con'))
        get :enroll, id: participant.id
      end

      it 'redirect_to to the logout page' do
        expect(response).to redirect_to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        expect(flash['error']).to eq 'Access Denied'
      end
    end
  end

  describe '#create' do
    it 'creates the empty participant and account_participant' do
      post :create, account_id: account.id
      expect(account.participants.size).to eq 1
      expect(account.account_participants.size).to eq 1
    end

    it 'creates the empty child participant and account_participant' do
      post :create, account_id: account.id, child: 'true'
      expect(account.participants.first.child).to be true
    end
  end

  private
    def setup_survey(code)
      survey = FactoryGirl.create(:survey, code: code, multiple_section: false)
      survey.sections.first.questions.create(text: 'question 1', response_type: 'date')
      survey.state = 'active'
      survey.save
      survey
    end
end