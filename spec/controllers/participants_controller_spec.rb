require 'rails_helper'

RSpec.describe ParticipantsController, type: :controller do
  setup :activate_authlogic
  let(:account) { FactoryGirl.create(:account) }
  let(:participant) { FactoryGirl.create(:participant, stage: 'approved', address_line1: '123 Main St', address_line2: 'Apt #123', city: 'Chicago', state: 'IL', zip: '12345', email: 'test@test.com', primary_phone: '123-456-7890', secondary_phone: '123-345-6789')}

  before(:each) do
    @adult_survey = setup_survey('adult')
    @child_survey = setup_survey('child')
    account.participants << participant
    account.save!
  end

  describe 'authorized access' do
    describe 'POST create' do
      describe 'with valid parameters' do
        it 'creates participant' do
          expect {
            post :create, account_id: account.id
          }.to change{ Participant.count }.by(1)
        end

        it 'creates account_participant' do
          expect {
            post :create, account_id: account.id
          }.to change{ AccountParticipant.count }.by(1)
        end

        it 'links created participant to account' do
          post :create, account_id: account.id
          expect(Participant.last.account).to eq account
        end

        it 'links created account_participant to account' do
          post :create, account_id: account.id
          expect(AccountParticipant.last.account).to eq account
        end

        it 'sets proxy value from parameters' do
          post :create, account_id: account.id, proxy: 'true'
          expect(account.account_participants.last.proxy).to be true
        end

        it 'creates child participant if specified' do
          post :create, account_id: account.id, child: 'true'
          expect(account.participants.last.child).to be true
        end

        it 'copies data from existing active participants' do
          other_participant = FactoryGirl.create(:participant)
          account.participants << other_participant
          account.save!

          post :create, account_id: account.id
          expect(account.participants.last.address_line1).to eq account.participants.first.address_line1
        end

        it 'redirects to participant enrollment page' do
          post :create, account_id: account.id
          expect(response).to redirect_to(controller: :participants, action: :enroll, id: account.participants.last.id)
        end
      end

      describe 'with invalid parameters' do
        before(:each) do
          allow_any_instance_of(AccountParticipant).to receive(:save).and_return(false)
        end

        it 'redirects to dashboard' do
          post :create, account_id: account.id
          expect(response).to redirect_to(controller: :accounts, action: :dashboard)
        end

        it 'sets error flash' do
          post :create, account_id: account.id
          expect(flash['error']).not_to be_nil
        end
      end
    end

    describe 'GET show' do
      it 'renders show template' do
        get :show, id: participant.id
        expect(response).to render_template('show')
      end
    end

    describe 'POST update' do
      describe 'with valid parameters' do
        it 'updates participant attributes' do
          post :update, id: participant.id, participant: { first_name: 'Azazello'}
          expect(participant.reload.first_name).to eq 'Azazello'
        end

        it 'updates participant relationship attributes' do
          other_participant = FactoryGirl.create(:participant)
          account.participants << other_participant
          account.save!
          origin_relationship = participant.origin_relationships.create!( category: 'Parent', destination_id: other_participant.id)

          post :update, id: participant.id, participant: { first_name: 'Azazello', origin_relationships_attributes: { id: origin_relationship.id, category: 'Guardian'}}
          expect(origin_relationship.reload.category).to eq 'Guardian'
        end

        it 'redirects to enroll page' do
          post :update, id: participant.id, participant: { first_name: 'Azazello'}
          expect(response).to redirect_to( controller: :participants, action: :enroll, id: participant.id)
        end

        describe 'when participant is at survey state' do
          before(:each) do
            participant.stage = 'survey'
            participant.save
          end

          it 'creates a new response set' do
            expect {
              post :update, id: participant.id, participant: { first_name: 'Azazello'}
            }.to change{ ResponseSet.count }.by(1)
            expect(participant.response_sets.size).to eq 1
          end

          it 'redirects to new response_set edit page' do
            post :update, id: participant.id, participant: { first_name: 'Azazello'}
            expect(response).to redirect_to(controller: :response_sets, action: :edit, id: participant.reload.response_sets.last.id)
          end

          it 'creates a new response set for a child survey if participant is a child proxy' do
            participant.child = true
            participant.account_participant.proxy = true
            participant.account_participant.save
            participant.save
            post :update, id: participant.id, participant: { first_name: 'Azazello'}
            expect(participant.response_sets.last.survey).to eq @child_survey
          end
        end
      end

      describe 'with invalid parameters' do
        before(:each) do
          allow_any_instance_of(Participant).to receive(:save).and_return(false)
        end

        it 'renders error flash' do
          post :update, id: participant.id, participant: { first_name: 'Azazello'}
          expect(flash['error']).not_to be_nil
        end
      end
    end

    describe 'GET enroll' do
      it 'returns the participant' do
        get :enroll, id: participant.id
        expect(flash['error']).to be_nil
      end

      it 'copies data from existing active participants' do
        other_participant = FactoryGirl.create(:participant)
        account.participants << other_participant
        account.save!
        get :enroll, id: other_participant.id
        expect(account.participants.last.address_line1).to eq account.participants.first.address_line1
      end

      it 'renders enroll template' do
        get :enroll, id: participant.id
        expect(response).to render_template('enroll')
      end

      it 'redirects to dashboard if participant consent is denied' do
        participant.stage = 'consent_denied'
        participant.save
        get :enroll, id: participant.id
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      describe 'when participant is at survey state' do
        before(:each) do
          participant.stage = 'survey'
          participant.save
        end

        describe 'when response set does not exist' do
          it 'creates a new response set' do
            expect {
              get :enroll, id: participant.id
            }.to change{ ResponseSet.count }.by(1)
            expect(participant.response_sets.size).to eq 1
          end

          it 'redirects to new response_set edit page' do
            get :enroll, id: participant.id
            expect(response).to redirect_to(controller: :response_sets, action: :edit, id: participant.reload.response_sets.last.id)
          end

          it 'creates a new response set for a child survey if participant is a child proxy' do
            participant.child = true
            participant.account_participant.proxy = true
            participant.account_participant.save
            participant.save
            get :enroll, id: participant.id
            expect(participant.response_sets.last.survey).to eq @child_survey
          end
        end

        describe 'when response set exists' do
          it 'uses existing reponse if available' do
            participant.create_response_set(@adult_survey)
            expect {
              get :enroll, id: participant.id
            }.not_to change{ ResponseSet.count }
            expect(participant.response_sets.size).to eq 1
          end

          it 'redirects to new response_set edit page' do
            get :enroll, id: participant.id
            expect(response).to redirect_to(controller: :response_sets, action: :edit, id: participant.response_sets.last.id)
          end
        end
      end
    end

    describe 'GET consent' do
      it 'renders consent template' do
        get :consent, id: participant.id
        expect(response).to render_template('consent')
      end
    end

    describe 'POST consent signature' do
      before(:each) do
        participant.stage = 'consent'
        participant.save!
      end

      describe 'with valid params' do
        it 'transitions participant to consented state if consent is accepted' do
          post :consent_signature, id: participant.id, consent_response: 'accept', consent_signature: { date: Date.today, consent_id: @adult_survey.id, proxy_name: 'Little My', proxy_relationship: 'Parent'}
          expect(participant.reload.stage).to eq 'consent'
          expect(response).to redirect_to(controller: :participants, action: :enroll, id: participant.id)
        end

        it 'transitions participant to consent denied state if consent is not accepted' do
          post :consent_signature, id: participant.id, consent_response: 'blah'
          expect(participant.reload.stage).to eq 'consent_denied'
          expect(response).to redirect_to(controller: :participants, action: :enroll, id: participant.id)
        end
      end

      describe 'with invalid params' do
        it 'redirects to dashboard' do
          post :consent_signature, id: participant.id, consent_response: 'accept', consent_signature: { proxy_name: 'hello'}
          expect(response).to redirect_to(controller: :participants, action: :enroll, id: participant.id)
        end

        it 'sets error flash' do
          post :consent_signature, id: participant.id, consent_response: 'accept', consent_signature: {proxy_name: 'hello'}
          expect(flash['error']).not_to be_nil
        end
      end
    end
  end

  describe 'unauthorized access' do
    before(:each) do
      AccountSession.create(FactoryGirl.create(:account, email: 'other@test.con'))
    end

    describe 'POST create' do
      it 'does not create a participant' do
        expect {
          post :create, account_id: '999999'
        }.not_to change{ Participant.count }
      end

      it 'redirects to dashboard' do
        post :create, account_id: '999999'
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end
    end

    describe 'GET show' do
      it 'redirects to dashboard' do
        get :show, id: participant.id
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        get :show, id: participant.id
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'POST update' do
      it 'redirects to dashboard' do
        post :update, id: participant.id
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end
    end

    describe 'GET enroll' do
      it 'redirects to dashboard' do
        get :enroll, id: participant.id
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        get :enroll, id: participant.id
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'GET consent' do
      it 'redirects to dashboard' do
        get :consent, id: participant.id
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        get :consent, id: participant.id
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'POST consent signature' do
      it 'redirects to dashboard' do
        post :consent_signature, id: participant.id
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        post :consent_signature, id: participant.id
        expect(flash['error']).to eq 'Access Denied'
      end
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