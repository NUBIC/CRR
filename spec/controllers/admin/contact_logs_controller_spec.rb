require 'rails_helper'

RSpec.describe Admin::ContactLogsController, type: :controller do
  before(:each) do
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @participant    = FactoryGirl.create(:participant)
    @contact_log    = FactoryGirl.create(:contact_log)
    @valid_params   = { participant_id: @participant.id, date: Date.today, mode: ContactLog::MODES.sample }
    @invalid_params = { participant_id: @participant.id, date: Date.today, mode: 'zzMode' }
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

      describe 'GET new' do
        it 'redirects to dashboard' do
          get :new, participant_id: @participant.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :new, participant_id: @participant.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST create' do
        it 'redirects to dashboard' do
          post :create, contact_log: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :create, contact_log: @valid_params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET edit' do
        it 'redirects to dashboard' do
          get :edit, id: @contact_log.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :edit, id: @contact_log.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST update' do
        it 'redirects to dashboard' do
          post :update, id: @contact_log.id, contact_log: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :update, id: @contact_log.id, contact_log: @valid_params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST destroy' do
        it 'redirects to dashboard' do
          post :destroy, id: @contact_log.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :destroy, id: @contact_log.id
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

      describe 'GET new' do
        it 'renders new template' do
          get :new, participant_id: @participant.id
          expect(response).to render_template('new')
        end
      end

      describe 'POST create' do
        describe 'with valid parameters' do
          it 'creates a contact log' do
            expect {
              post :create, contact_log: @valid_params
            }.to change{ContactLog.count}.by(1)
          end

          it 'redirects to participant page' do
            post :create, id: @contact_log.id, contact_log: @valid_params
            expect(response).to redirect_to(controller: :participants, action: :show, id: @participant.id)
          end
        end

        describe 'with invalid parameters' do
          it 'does not create a contact_log' do
            expect {
              post :create, contact_log: @invalid_params
            }.not_to change{ContactLog.count}
          end

          it 'redirects to new' do
            post :create, contact_log: @invalid_params
            expect(response).to redirect_to(controller: :contact_logs, action: :new, participant_id: @participant.id)
          end

          it 'displays error message' do
            post :create, contact_log: @invalid_params
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'GET edit' do
        it 'renders edit template' do
          get :edit, id: @contact_log.id
          expect(response).to render_template('edit')
        end
      end

      describe 'POST update' do
        describe 'with valid parameters' do
          it 'redirects to participant page' do
            post :update, id: @contact_log.id, contact_log: @valid_params
            expect(response).to redirect_to(controller: :participants, action: :show, id: @contact_log.participant.id)
          end
        end

        describe 'with invalid parameters' do
          before(:each) do
            post :update, id: @contact_log.id, contact_log: @invalid_params
          end

          it 'redirects to edit' do
            expect(response).to redirect_to(controller: :contact_logs, action: :edit, id: @contact_log.id)
          end

          it 'displays error message' do
            expect(flash['error']).not_to be_nil
          end
        end
      end

      describe 'POST destroy' do
        it 'destroys search_condition' do
          expect {
            post :destroy, id: @contact_log.id
          }.to change{ContactLog.count}.by(-1)
        end

        it 'redirects to participant page' do
          post :destroy, id: @contact_log.id
          expect(response).to redirect_to(controller: :participants, action: :show, id: @contact_log.participant.id)
        end
      end
    end
  end
end