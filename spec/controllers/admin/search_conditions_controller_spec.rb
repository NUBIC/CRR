require 'rails_helper'

RSpec.describe Admin::SearchConditionsController, type: :controller do
  before(:each) do
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @study = FactoryBot.create(:study)
    @survey       = FactoryBot.create(:survey, multiple_section: false)
    @section      = @survey.sections.first
    @q_pick_many  = @section.questions.create(text: 'test',  response_type: 'pick_many',  is_mandatory: true, code: 'q_many')
    @pm_a1 = @q_pick_many.answers.create(text: 'one')
    @pm_a2 = @q_pick_many.answers.create(text: 'two')
    @pm_a3 = @q_pick_many.answers.create(text: 'three')
    @pm_a4 = @q_pick_many.answers.create(text: 'four')

    @search = @study.searches.create( name: 'test' )
    @search_condition_group = @search.search_condition_group
    @search_condition = @search_condition_group.search_conditions.create(question: @q_pick_many, operator: 'in', values: [@pm_a1.id.to_s, @pm_a2.id.to_s])

    @valid_params   = { search_condition_group_id: @search_condition_group.id, operator: 'in', question_id: @q_pick_many.id, values: [ @pm_a1.id.to_s, @pm_a2.id.to_s] }
    @invalid_params = { operator: 'hello', search_condition_group_id: @search_condition_group.id }
  end

  describe 'unauthorized access' do
    ['data_manager?', 'researcher?', 'admin?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(role.to_sym).and_return(false)
      end

      describe 'POST create' do
        it 'redirects to dashboard' do
          post :create, params: { search_condition: @valid_params }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :create, params: { search_condition: @valid_params }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST update' do
        it 'redirects to dashboard' do
          post :update, params: { id: @search_condition.id, search_condition: @valid_params }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :update, params: { id: @search_condition.id, search_condition: @valid_params }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST destroy' do
        it 'redirects to dashboard' do
          post :destroy, params: { id: @search_condition.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :destroy, params: { id: @search_condition.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET values' do
        it 'redirects to dashboard' do
          get :values, params: { id: @search_condition.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :values, params: { id: @search_condition.id }
          expect(flash['error']).to eq 'Access Denied'
        end
      end
    end
  end

  describe 'authorized access' do
    ['admin?', 'data_manager?', 'researcher?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(role.to_sym).and_return(true)
      end

      describe 'POST create' do
        describe 'with valid parameters' do
          it 'creates a search_condition' do
            expect {
              post :create, params: { search_condition: @valid_params }
            }.to change{SearchCondition.count}.by(1)
          end

          it 'renders show view' do
            post :create, params: { search_condition: @valid_params }
            expect(response).to render_template('show')
          end
        end

        describe 'with invalid parameters' do
          it 'does not create a participant' do
            expect {
              post :create, params: { search_condition: @invalid_params }
            }.not_to change{SearchCondition.count}
          end

          it 'renders new view' do
            post :create, params: { search_condition: @invalid_params }
            expect(response).to render_template('new')
          end

          it 'displays error message' do
            post :create, params: { search_condition: @invalid_params }
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'POST update' do
        describe 'with valid parameters' do
          it 'renders show view' do
            post :update, params: { id: @search_condition.id, search_condition: @valid_params }
            expect(response).to render_template('show')
          end
        end

        describe 'with invalid parameters' do
          before(:each) do
            post :update, params: { id: @search_condition.id, search_condition: @invalid_params }
          end

          it 'renders edit view' do
            expect(response).to render_template('edit')
          end

          it 'displays error message' do
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'POST destroy' do
        it 'destroys search_condition' do
          expect {
            post :destroy, params: { id: @search_condition.id }
          }.to change{SearchCondition.count}.by(-1)
        end

        it 'redirects to participant page' do
          post :destroy, params: { id: @search_condition.id }
          expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
        end
      end

      describe 'GET values' do
        it 'renders values view' do
          get :values, params: { id: @search_condition.id }
          expect(response).to render_template('values')
        end

        it 'assigns question if requested through params' do
          get :values, params: { id: @search_condition.id, question_id: @q_pick_many.id }
          expect(assigns(:question)).to eq @q_pick_many
        end
      end
    end
  end
end