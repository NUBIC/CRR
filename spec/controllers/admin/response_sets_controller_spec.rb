require 'rails_helper'

RSpec.describe Admin::ResponseSetsController, type: :controller do
  before(:each) do
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @participant    = FactoryGirl.create(:participant)
    @survey         = setup_survey('survey')
    @response_set   = @participant.response_sets.create(survey: @survey)
    @params   = { survey_id: @survey.id, participant_id: @participant.id }
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
          xhr :get, :index, participant_id: @participant.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :index, participant_id: @participant.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET new' do
        it 'redirects to dashboard' do
          xhr :get, :new, participant_id: @participant.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          xhr :get, :new, participant_id: @participant.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST create' do
        it 'redirects to dashboard' do
          post :create, response_set: @params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :create, response_set: @params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET edit' do
        it 'redirects to dashboard' do
          get :edit, id: @response_set.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :edit, id: @response_set.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST update' do
        it 'redirects to dashboard' do
          post :update, id: @response_set.id, response_set: @params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :update, id: @response_set.id, response_set: @params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST destroy' do
        it 'redirects to dashboard' do
          post :destroy, id: @response_set.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :destroy, id: @response_set.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end
    end
  end

  describe 'authorized access' do
    ['data_manager?', 'admin?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:researcher?).and_return(true)
        all_roles = ['data_manager?', 'admin?']
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
          xhr :get, :index, participant_id: @participant.id
          expect(response).to render_template('index')
        end
      end

      describe 'GET new' do
        it 'renders new template' do
          xhr :get, :new, participant_id: @participant.id
          expect(response).to render_template('new')
        end
      end

      describe 'POST create' do
        describe 'with valid parameters' do
          it 'creates a response_set' do
            expect {
              post :create, response_set: @params
            }.to change{ResponseSet.count}.by(1)
          end

          it 'redirects to participant page if response_set is public' do
            allow_any_instance_of(ResponseSet).to receive(:public?).and_return(true)
            post :create, id: @response_set.id, response_set: @params
            expect(response).to redirect_to(controller: :participants, action: :show, id: @participant.id, tab: 'surveys')
          end

          it 'redirects to edit page if response_set is not public' do
            allow_any_instance_of(ResponseSet).to receive(:public?).and_return(false)
            post :create, id: @response_set.id, response_set: @params
            expect(response).to redirect_to(controller: :response_sets, action: :edit, id: ResponseSet.last.id)
          end
        end

        describe 'with invalid parameters' do
          before(:each) do
            allow_any_instance_of(ResponseSet).to receive(:save).and_return(false)
          end

          it 'does not create a response_set' do
            expect {
              post :create, response_set: @params
            }.not_to change{ResponseSet.count}
          end

          it 'renders new template' do
            post :create, response_set: @params
            expect(response).to render_template('new')
          end

          it 'displays error message' do
            post :create, response_set: @params
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'GET edit' do
        it 'renders edit template' do
          get :edit, id: @response_set.id
          expect(response).to render_template('edit')
        end
      end

      describe 'POST update' do
        describe 'with valid parameters' do
          it 'redirects to edit page in html format' do
            post :update, id: @response_set.id, response_set: @params
            expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
          end

          it 'renders edit page in js format' do
            xhr :post, :update, id: @response_set.id, response_set: @params
            expect(response).to render_template('edit')
          end

          describe 'with incomplete response_set' do
            before(:each) do
              allow(@response_set).to receive(:complete!).and_return(false)
            end

            describe 'if finish parameter is not specified' do
              it 'redirects to edit page in html format' do
                post :update, id: @response_set.id, response_set: @params
                expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
              end

              it 'renders edit page in js format' do
                xhr :post, :update, id: @response_set.id, response_set: @params
                expect(response).to render_template('edit')
              end
            end

            describe 'if finish parameter is specified' do
              it 'redirects to dashboard in html format' do
                post :update, id: @response_set.id, response_set: @params, button: 'finish'
                expect(response).to redirect_to(controller: :participants, action: :show, id: @response_set.participant.id, tab: 'surveys')
              end
            end
          end
        end

        describe 'with invalid response set parameters' do
          before(:each) do
            allow_any_instance_of(ResponseSet).to receive(:save).and_return(false)
          end

          it 'redirects to edit page in html format' do
            post :update, id: @response_set.id, response_set: @params
            expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
          end

          it 'assigns errors to flash in html format' do
            post :update, id: @response_set.id, response_set: @params
            expect(flash['error']).not_to be_nil
          end

          it 'renders edit page in js format' do
            xhr :post, :update, id: @response_set.id, response_set: @params
            expect(response).to render_template('edit')
          end

          it 'assigns errors to flash in js format' do
            xhr :post, :update, id: @response_set.id, response_set: @params
            expect(flash['error']).not_to be_nil
          end

          describe 'with incomplete response_set' do
            before(:each) do
              allow(@response_set).to receive(:complete!).and_return(false)
            end

            describe 'if finish parameter is not specified' do
              it 'redirects to edit page in html format' do
                post :update, id: @response_set.id, response_set: @params
                expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
              end

              it 'assigns errors to flash in html format' do
                post :update, id: @response_set.id, response_set: @params
                expect(flash['error']).not_to be_nil
              end

              it 'renders edit page in js format' do
                xhr :post, :update, id: @response_set.id, response_set: @params
                expect(response).to render_template('edit')
              end

              it 'assigns errors to flash in js format' do
                xhr :post, :update, id: @response_set.id, response_set: @params
                expect(flash['error']).not_to be_nil
              end
            end

            describe 'if finish parameter is specified' do
              it 'redirects to edit page in html format' do
                post :update, id: @response_set.id, response_set: @params
                expect(response).to redirect_to(controller: :response_sets, action: :edit, id: @response_set.id)
              end

              it 'assigns errors to flash in html format' do
                post :update, id: @response_set.id, response_set: @params
                expect(flash['error']).not_to be_nil
              end

              it 'renders edit page in js format' do
                xhr :post, :update, id: @response_set.id, response_set: @params
                expect(response).to render_template('edit')
              end

              it 'assigns errors to flash in js format' do
                xhr :post, :update, id: @response_set.id, response_set: @params
                expect(flash['error']).not_to be_nil
              end
            end
          end
        end
      end

      describe 'POST destroy' do
        it 'destroys response set' do
          expect {
            post :destroy, id: @response_set.id
          }.to change{ResponseSet.count}.by(-1)
        end

        it 'redirects to participant page' do
          post :destroy, id: @response_set.id
          expect(response).to redirect_to(controller: :participants, action: :show, id: @response_set.participant.id, tab: 'surveys')
        end
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