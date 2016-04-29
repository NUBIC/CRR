require 'spec_helper'

describe Admin::StudyInvolvementsController do
  before(:each) do
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @participant        = FactoryGirl.create(:participant, stage: 'approved')
    @study              = FactoryGirl.create(:study)
    @valid_params       = { participant_id: @participant.id, study_id: @study.id, start_date: Date.today, end_date: Date.tomorrow }
    @invalid_params     = { participant_id: @participant.id, study_id: @study.id, end_date: Date.today, start_date: Date.tomorrow }
    @study_involvement  = FactoryGirl.create(:study_involvement)
  end

  describe 'unauthorized access' do
    ['data_manager?', 'researcher?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:admin?).and_return(false)
        all_roles = ['data_manager?','researcher?']
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
          get :index, participant_id: @participant.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :index, participant_id: @participant.id
          expect(flash['error']).to eq 'Access Denied'
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
          post :create, study_involvement: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :create, study_involvement: @valid_params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET edit' do
        it 'redirects to dashboard' do
          get :edit, id: @study_involvement.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :edit, id: @study_involvement.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST update' do
        it 'redirects to dashboard' do
          post :update, id: @study_involvement.id, study_involvement: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :update, id: @study_involvement.id, study_involvement: @valid_params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST destroy' do
        it 'redirects to dashboard' do
          post :destroy, id: @study_involvement.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :destroy, id: @study_involvement.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end
    end
  end

  describe 'authorized access' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
    end

    describe 'GET index' do
      before(:each) do
        get :index, participant_id: @participant.id
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end

      it 'assigns participant' do
        expect(assigns(:participant)).to eq @participant
      end
    end

    describe 'GET new' do
      before(:each) do
        get :new, participant_id: @participant.id
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'assigns participant' do
        expect(assigns(:participant)).to eq @participant
      end
    end

    describe 'POST create' do
      describe 'with valid parameters' do
        it 'creates a participant' do
          expect {
            post :create, study_involvement: @valid_params
          }.to change{StudyInvolvement.count}.by(1)
        end

        it 'redirects to participant page' do
          post :create, study_involvement: @valid_params
          expect(response).to redirect_to(controller: :participants, action: :show, id: @participant.id)
        end
      end

      describe 'with invalid parameters' do
        it 'does not create a participant' do
          expect {
            post :create, study_involvement: @invalid_params
          }.not_to change{StudyInvolvement.count}
        end

        it 'redirects to new involvement page' do
          post :create, study_involvement: @invalid_params
          expect(response).to redirect_to(controller: :study_involvements, action: :new, participant_id: @participant.id)
        end

        it 'displays error message' do
          post :create, study_involvement: @invalid_params
          expect(flash['error']).not_to be_nil
        end
      end
    end

    describe 'GET edit' do
      before(:each) do
        get :edit, id: @study_involvement.id
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns participant' do
        expect(assigns(:participant)).to eq @study_involvement.participant
      end
    end

    describe 'POST update' do
      describe 'with valid parameters' do
        it 'redirects to participant page' do
          post :update, id: @study_involvement.id, study_involvement: @valid_params
          expect(response).to redirect_to(controller: :participants, action: :show, id: @participant.id)
        end
      end

      describe 'with invalid parameters' do
        before(:each) do
          post :update, id: @study_involvement.id, study_involvement: @invalid_params
        end

        it 'redirects to edit involvement page' do
          expect(response).to redirect_to(controller: :study_involvements, action: :edit, id: @study_involvement.id)
        end

        it 'displays error message' do
          expect(flash['error']).not_to be_nil
        end
      end
    end

    describe 'POST destroy' do
      it 'destroys study_involvement' do
        expect {
          post :destroy, id: @study_involvement.id
        }.to change{StudyInvolvement.count}.by(-1)
      end

      it 'redirects to participant page' do
        post :destroy, id: @study_involvement.id
        expect(response).to redirect_to(controller: :participants, action: :show, id: @study_involvement.participant.id)
      end
    end
  end
end