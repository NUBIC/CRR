require 'spec_helper'

describe Admin::SearchConditionGroupsController do
  before(:each) do
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @study = FactoryGirl.create(:study)
    @search = @study.searches.create( name: 'test' )
    @search_condition_group = @search.search_condition_group
    @valid_params   = { operator: '|', search_condition_group_id: @search_condition_group.id }
    @invalid_params = { operator: 'hello', search_condition_group_id: @search_condition_group.id }
  end

  describe 'unauthorized access' do
    ['data_manager?', 'researcher?', 'admin?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(role.to_sym).and_return(false)
      end

      describe 'POST create' do
        it 'redirects to dashboard' do
          post :create, search_condition_group: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :create, search_condition_group: @valid_params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST update' do
        it 'redirects to dashboard' do
          post :update, id: @search_condition_group.id, search_condition_group: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :update, id: @search_condition_group.id, search_condition_group: @valid_params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST destroy' do
        it 'redirects to dashboard' do
          post :destroy, id: @search_condition_group.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :destroy, id: @search_condition_group.id
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
          it 'creates a search_condition_group' do
            expect {
              post :create, search_condition_group: @valid_params
            }.to change{SearchConditionGroup.count}.by(1)
          end

          it 'redirects to search page' do
            post :create, search_condition_group: @valid_params
            expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
          end
        end

        describe 'with invalid parameters' do
          it 'does not create a participant' do
            expect {
              post :create, search_condition_group: @invalid_params
            }.not_to change{SearchConditionGroup.count}
          end

          it 'redirects to to search page' do
            post :create, search_condition_group: @invalid_params
            expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
          end

          it 'displays error message' do
            post :create, search_condition_group: @invalid_params
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'POST update' do
        describe 'with valid parameters' do
          it 'redirects to search page' do
            post :update, id: @search_condition_group.id, search_condition_group: @valid_params
            expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
          end
        end

        describe 'with invalid parameters' do
          before(:each) do
            post :update, id: @search_condition_group.id, search_condition_group: @invalid_params
          end

          it 'redirects to search page' do
            expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
          end

          it 'displays error message' do
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'POST destroy' do
        it 'destroys search_condition_group' do
          expect {
            post :destroy, id: @search_condition_group.id
          }.to change{SearchConditionGroup.count}.by(-1)
        end

        it 'redirects to participant page' do
          post :destroy, id: @search_condition_group.id
          expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
        end
      end
    end
  end
end