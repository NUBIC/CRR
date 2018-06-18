require 'rails_helper'

RSpec.describe Admin::ParticipantsController, type: :controller do
  before(:each) do
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @adult_survey = setup_survey('adult')
    @child_survey = setup_survey('child')
    @params = { first_name: 'Joe', last_name: 'Doe'}
    @participant = FactoryBot.create(:participant, first_name: 'Joe', last_name: 'Doe', stage: 'approved', address_line1: '123 Main St', address_line2: 'Apt #123', city: 'Chicago', state: 'IL', zip: '12345', email: 'test@test.com', primary_phone: '123-456-7890', secondary_phone: '123-345-6789')

  end

  describe 'unauthorized access' do
    ['researcher?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:admin?).and_return(false)
        all_roles = ['data_manager?', 'researcher?']
        all_roles.each do |r|
          if r.eql?(role)
            allow(controller.current_user).to receive(r.to_sym).and_return(true)
          else
            allow(controller.current_user).to receive(r.to_sym).and_return(false)
          end
        end
      end

      describe 'GET index' do
        it 'redirects to dashboard' do
          get :index
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :index
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET new' do
        it 'redirects to dashboard' do
          get :new
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :new
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST create' do
        it 'redirects to dashboard' do
          post :create, params: { participant: @params }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :create, params: { participant: @params }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET show' do
        it 'redirects to dashboard' do
          get :show, params: { id: @participant.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :show, params: { id: @participant.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET edit' do
        it 'redirects to dashboard' do
          get :edit, params: { id: @participant.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :edit, params: { id: @participant.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST update' do
        it 'redirects to dashboard' do
          post :update, params: { id: @participant.id, participant: @params }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :update, params: { id: @participant.id, participant: @params }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET global' do
        it 'redirects to dashboard' do
          get :global
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :global
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET enroll' do
        it 'redirects to dashboard' do
          get :enroll, params: { id: @participant.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :enroll, params: { id: @participant.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST consent signature' do
        it 'redirects to dashboard' do
          post :consent_signature, params: { id: @participant.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :consent_signature, params: { id: @participant.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST withdraw' do
        it 'redirects to dashboard' do
          post :withdraw, params: { id: @participant.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :withdraw, params: { id: @participant.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST suspend' do
        it 'redirects to dashboard' do
          post :withdraw, params: { id: @participant.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :withdraw, params: { id: @participant.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST verify' do
        it 'redirects to dashboard' do
          post :verify, params: { id: @participant.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :verify, params: { id: @participant.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET search' do
        it 'redirects to dashboard' do
          get :search
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :search
          expect(flash['error']).to eq 'Access Denied'
        end
      end
    end
  end

  describe 'authorized access to released participants' do
    ['researcher?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:admin?).and_return(false)
        all_roles = ['data_manager?', 'researcher?']
        all_roles.each do |r|
          if r.eql?(role)
            allow(controller.current_user).to receive(r.to_sym).and_return(true)
          else
            allow(controller.current_user).to receive(r.to_sym).and_return(false)
          end
        end
        @study  = FactoryBot.create(:study)
        @study.activate
        @study.save
        @study_involvement  = FactoryBot.create(:study_involvement, study: @study, participant: @participant, start_date: Date.today, end_date: Date.tomorrow)
        allow(controller.current_user).to receive(:studies).and_return(Study.where(id: @study.id))
      end

      describe 'GET show' do
        it 'renders show template' do
          get :show, params: { id: @participant.id }
          expect(response).to render_template('show')
        end
      end
    end
  end

  describe 'authorized access' do
    ['data_manager?', 'admin?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:researcher?).and_return(true)
        all_roles = ['data_manager?', 'admin?', 'researcher?']
        all_roles.each do |r|
          if r.eql?(role)
            allow(controller.current_user).to receive(r.to_sym).and_return(true)
          else
            allow(controller.current_user).to receive(r.to_sym).and_return(false)
          end
        end
      end

      describe 'GET index' do
        it 'renders index template' do
          get :index
          expect(response).to render_template('index')
        end
      end

      describe 'GET new' do
        it 'renders new template' do
          get :new
          expect(response).to render_template('new')
        end
      end

      describe 'POST create' do
        describe 'with valid parameters' do
          it 'creates participant' do
            expect {
              post :create, params: { participant: @params }
            }.to change{ Participant.count }.by(1)
          end

          it 'redirects to participant enrollment page' do
            post :create, params: { participant: @params }
            expect(response).to redirect_to(controller: :participants, action: :enroll, id: Participant.last.id)
          end
        end

        describe 'with invalid parameters' do
          before(:each) do
            allow_any_instance_of(Participant).to receive(:save).and_return(false)
            post :create, params: { participant: @params }
          end

          it 'renders new template' do
            expect(response).to render_template('new')
          end

          it 'sets error flash' do
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'GET show' do
        it 'renders show template' do
          get :show, params: { id: @participant.id }
          expect(response).to render_template('show')
        end
      end

      describe 'GET edit' do
        it 'renders edit template' do
          get :edit, params: { id: @participant.id }
          expect(response).to render_template('edit')
        end
      end

      describe 'POST update' do
        describe 'with valid parameters' do
          it 'redirects to participant page' do
            post :update, params: { id: @participant.id, participant: @params }
            expect(response).to redirect_to( controller: :participants, action: :show, id: @participant.id)
          end

          describe 'when participant is in democraphics state' do
            it 'transfers participant to survey state' do
              @participant.stage = 'demographics'
              @participant.save
              post :update, params: { id: @participant.id, participant: @params }
              expect(@participant.reload).to be_survey
            end
          end

          describe 'when participant is at survey or democraphics state' do
            ['democraphics', 'survey'].each do |stage|
              before(:each) do
                @participant.stage = stage
                @participant.save
              end

              it 'creates a new response set' do
                expect {
                  post :update, params: { id: @participant.id, participant: @params }
                }.to change{ ResponseSet.count }.by(1)
                expect(@participant.response_sets.size).to eq 1
              end

              it 'redirects to new response_set edit page' do
                post :update, params: { id: @participant.id, participant: @params }
                expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @participant.reload.response_sets.last.id)
              end

              it 'creates a new response set for a child survey if participant is a child proxy' do
                @participant.child = true
                @participant.save
                post :update, params: { id: @participant.id, participant: @params }
                expect(@participant.response_sets.last.survey).to eq @child_survey
              end
            end
          end
        end

        describe 'with invalid parameters' do
          before(:each) do
            allow_any_instance_of(Participant).to receive(:save).and_return(false)
          end

          it 'renders error flash' do
            post :update, params: { id: @participant.id, participant: @params }
            expect(flash['error']).not_to be_nil
          end

          it 'renders edit template' do
            post :update, params: { id: @participant.id, participant: @params }
            expect(response).to render_template('edit')
          end
        end
      end

      describe 'GET global' do
        it 'renders global template' do
          get :global
          expect(response).to render_template('global')
        end
      end

      describe 'GET enroll' do
        it 'returns the participant' do
          get :enroll, params: { id: @participant.id }
          expect(flash['error']).to be_nil
        end

        it 'renders enroll template' do
          get :enroll, params: { id: @participant.id }
          expect(response).to render_template('enroll')
        end

        describe 'when participant is at survey state' do
          before(:each) do
            @participant.stage = 'survey'
            @participant.save
          end

          describe 'when response set does not exist' do
            it 'creates a new response set' do
              expect {
                get :enroll, params: { id: @participant.id }
              }.to change{ ResponseSet.count }.by(1)
              expect(@participant.response_sets.size).to eq 1
            end

            it 'redirects to new response_set edit page' do
              get :enroll, params: { id: @participant.id }
              expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @participant.reload.response_sets.last.id)
            end
          end

          describe 'when response set exists' do
            it 'uses existing response if available' do
              @participant.create_response_set(@adult_survey)
              expect {
                get :enroll, params: { id: @participant.id }
              }.not_to change{ ResponseSet.count }
              expect(@participant.response_sets.size).to eq 1
            end

            it 'redirects to new response_set edit page' do
              get :enroll, params: { id: @participant.id }
              expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @participant.response_sets.last.id)
            end
          end
        end
      end

      describe 'POST consent signature' do
        before(:each) do
          @participant.stage = 'consent'
          @participant.save!
        end

        it 'transitions participant to consented state' do
          post :consent_signature, params: { id: @participant.id, consent_signature: { date: Date.today, consent_id: @adult_survey.id, proxy_name: 'Little My', proxy_relationship: 'Parent'}}
          expect(@participant.reload.stage).to eq 'demographics'
          expect(response).to redirect_to(controller: :participants, action: :enroll, id: @participant.id)
        end
      end

      describe 'POST withdraw' do
        it 'transitions participant to withdrawn state' do
          post :withdraw, params: { id: @participant.id }
          expect(@participant.reload.stage).to eq 'withdrawn'
          expect(response).to redirect_to(controller: :participants, action: :index)
        end
      end

      describe 'POST suspend' do
        it 'transitions participant to withdrawn state' do
          post :suspend, params: { id: @participant.id }
          expect(@participant.reload.stage).to eq 'suspended'
          expect(response).to redirect_to(controller: :participants, action: :index)
        end
      end

      describe 'POST verify' do
        it 'transitions participant to approved state' do
          @participant.stage = 'pending_approval'
          @participant.save!

          post :verify, params: { id: @participant.id }
          expect(@participant.reload.stage).to eq 'approved'
          expect(response).to redirect_to(controller: :participants, action: :show, id: @participant.id)
        end
      end

      describe 'GET search' do
        it 'returns all participants id query parameter is not specified' do
          get :search, format: :json
          expect(JSON.parse(response.body)).to match_array(Participant.all.map{|p| { 'id' => p.id, 'search_display' => p.search_display}})
        end

        it 'finds participant by name' do
          p_1 = FactoryBot.create(:participant, first_name: 'Joe', last_name: 'Moe')
          p_2 = FactoryBot.create(:participant, first_name: 'Linn', last_name: 'Din')
          get :search, params: { q: 'oe' }, format: :json
          expect(JSON.parse(response.body)).to match_array([@participant, p_1].map{|p| { 'id' => p.id, 'search_display' => p.search_display}})
        end
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