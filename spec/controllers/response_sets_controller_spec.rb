require 'rails_helper'

RSpec.describe ResponseSetsController, type: :controller do
  setup :activate_authlogic
  let(:account) { FactoryBot.create(:account) }
  let(:participant) { FactoryBot.create(:participant) }

  before(:each) do
    account_participant = FactoryBot.create(:account_participant, account: account, participant: participant, proxy: true)
    @survey         = setup_survey('survey')
    @response_set   = participant.response_sets.create(survey: @survey)
    @invalid_params = { survey_id: nil }
    @valid_params   = { updated_at: Time.now }
  end

  describe 'authorized access' do
    describe 'POST create' do
      describe 'with valid parameters' do
        before(:each) do
          @another_survey = setup_survey('another survey')
        end

        it 'creates a response_set' do
          expect {
            post :create, params: { participant_id: participant.id, response_set: { survey_id: @another_survey.id }}
          }.to change{ ResponseSet.count }.by(1)
        end

        it 'redirect_to to the edit page' do
          post :create, params: { participant_id: participant.id, response_set: { survey_id: @another_survey.id }}
          expect(response).to redirect_to(controller: :response_sets, action: :edit, id: participant.response_sets.last.id)
        end
      end

      describe 'with invalid parameters' do
        it 'does not create a response_set' do
          expect {
            post :create, params: { participant_id: participant.id }
          }.not_to change{ ResponseSet.count }
        end

        it 'redirect_to to the enroll page' do
          post :create, params: { participant_id: participant.id }
          expect(response).to redirect_to(controller: :participants, action: :enroll, id: participant.id)
        end
      end
    end

    describe 'GET show' do
      it 'assigns @survey' do
        get :show, params: { id: @response_set.id }
        expect(assigns(:survey)).to eq @response_set.survey
      end

      it 'renders show template' do
        get :show, params: { id: @response_set.id }
        expect(response).to render_template('show')
      end
    end

    describe 'GET edit' do
      it 'assigns @survey' do
        get :edit, params: { id: @response_set.id }
        expect(assigns(:survey)).to eq @response_set.survey
      end

      describe 'it assigns @section' do
        before(:each) do
          @survey.multiple_section = true
          @survey.save!
          @section = @survey.sections.create(title: 'section 1')
        end

        it 'as a first section by default' do
          get :edit, params: { id: @response_set.id }
          expect(assigns(:section)).to eq @response_set.survey.sections.first
        end

        it 'by section_id if provided' do
          get :edit, params: { id: @response_set.id, section_id: @section.id }
          expect(assigns(:section)).to eq @section
        end
      end

      it 'renders edit template' do
        get :edit, params: { id: @response_set.id }
        expect(response).to render_template('edit')
      end

      it 'responds to xhr edit request' do
        get :edit, xhr: true, params: { id: @response_set.id }
        expect(response).to render_template('edit')
      end
    end

    describe 'POST update' do
      describe 'with invalid response set parameters' do
        it 'redirects to edit page in html format' do
          post :update, params: { id: @response_set.id, response_set: @invalid_params }
          expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
        end

        it 'assigns errors to flash in html format' do
          post :update, params: { id: @response_set.id, response_set: @invalid_params }
          expect(flash['error']).to match(/Survey can't be blank/)
        end

        it 'renders edit page in js format' do
          post :update, xhr: true, params: { id: @response_set.id, response_set: @invalid_params }
          expect(response).to render_template('edit')
        end

        it 'assigns errors to flash in js format' do
          post :update, xhr: true, params: { id: @response_set.id, response_set: @invalid_params }
          expect(flash['error']).to match(/Survey can't be blank/)
        end

        describe 'with incomplete response_set' do
          before(:each) do
            allow(@response_set).to receive(:complete!).and_return(false)
          end

          describe 'if finish parameter is not specified' do
            it 'redirects to edit page in html format' do
              post :update, params: { id: @response_set.id, response_set: @invalid_params }
              expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
            end

            it 'assigns errors to flash in html format' do
              post :update, params: { id: @response_set.id, response_set: @invalid_params }
              expect(flash['error']).to match(/Survey can't be blank/)
            end

            it 'renders edit page in js format' do
              post :update, xhr: true, params: { id: @response_set.id, response_set: @invalid_params }
              expect(response).to render_template('edit')
            end

            it 'assigns errors to flash in js format' do
              post :update, xhr: true, params: { id: @response_set.id, response_set: @invalid_params }
              expect(flash['error']).to match(/Survey can't be blank/)
            end
          end

          describe 'if finish parameter is specified' do
            it 'redirects to edit page in html format' do
              post :update, params: { id: @response_set.id, response_set: @invalid_params }
              expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
            end

            it 'assigns errors to flash in html format' do
              post :update, params: { id: @response_set.id, response_set: @invalid_params }
              expect(flash['error']).to match(/Survey can't be blank/)
            end

            it 'renders edit page in js format' do
              post :update, xhr: true, params: { id: @response_set.id, response_set: @invalid_params }
              expect(response).to render_template('edit')
            end

            it 'assigns errors to flash in js format' do
              post :update, xhr: true, params: { id: @response_set.id, response_set: @invalid_params }
              expect(flash['error']).to match(/Survey can't be blank/)
            end
          end
        end
      end

      describe 'with valid response set parameters' do
        it 'redirects to edit page in html format' do
          post :update, params: { id: @response_set.id, response_set: @valid_params }
          expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
        end

        it 'renders edit page in js format' do
          post :update, xhr: true, params: { id: @response_set.id, response_set: @valid_params }
          expect(response).to render_template('edit')
        end

        describe 'with incomplete response_set' do
          before(:each) do
            allow(@response_set).to receive(:complete!).and_return(false)
          end

          describe 'if finish parameter is not specified' do
            it 'redirects to edit page in html format' do
              post :update, params: { id: @response_set.id, response_set: @valid_params }
              expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
            end

            it 'renders edit page in js format' do
              post :update, xhr: true, params: { id: @response_set.id, response_set: @valid_params }
              expect(response).to render_template('edit')
            end
          end

          describe 'if finish parameter is specified' do
            it 'redirects to dashboard in html format' do
              post :update, params: { id: @response_set.id, response_set: @valid_params, button: 'finish' }
              expect(response).to redirect_to("/dashboard?participant_id=#{participant.id}")
            end
          end
        end
      end

    end
  end

  describe 'unauthorized access' do
    before(:each) do
      AccountSession.create(FactoryBot.create(:account, email: 'other@test.con'))
    end

    describe 'POST create' do
      it 'does not create a response_set' do
        expect {
          post :create, params: { participant_id: participant.id }
        }.not_to change{ ResponseSet.count }
      end

      it 'redirect_to to the logout page' do
        post :create, params: { participant_id: participant.id }
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        post :create, params: { participant_id: participant.id }
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'GET show' do
      it 'redirect_to to the logout page' do
        get :show, params: { id: @response_set.id }
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        get :show, params: { id: @response_set.id }
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'GET edit' do
      it 'redirect_to to the logout page' do
        get :edit, params: { id: @response_set.id }
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        get :edit, params: { id: @response_set.id }
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'POST update' do
      it 'redirect_to to the logout page' do
        post :update, params: { id: @response_set.id }
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end

      it 'displays "Access Denied" flash message' do
        post :update, params: { id: @response_set.id }
        expect(flash['error']).to eq 'Access Denied'
      end
    end
  end

  private
    def setup_survey(code)
      survey = FactoryBot.create(:survey, code: code, multiple_section: false)
      survey.sections.first.questions.create(text: 'question 1', response_type: 'date')
      survey.state = 'active'
      survey.save
      survey
    end
end
