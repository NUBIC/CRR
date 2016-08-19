require 'rails_helper'

RSpec.describe Admin::StudyInvolvementsController, type: :controller do
  before(:each) do
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @participant        = FactoryGirl.create(:participant, stage: 'approved')
    @study              = FactoryGirl.create(:study)
    @params             = { participant_id: @participant.id, study_id: @study.id, start_date: Date.today, end_date: Date.tomorrow, study_involvement_status_attributes: { name: StudyInvolvementStatus.valid_statuses.sample[:name] }}
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

      describe 'GET new' do
        before(:each) do
          get :new, participant_id: @participant.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST create' do
        before(:each) do
          post :create, study_involvement: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'GET edit' do
        before(:each) do
          get :edit, id: @study_involvement.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST update' do
        before(:each) do
          post :update, id: @study_involvement.id, study_involvement: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST destroy' do
        before(:each) do
          post :destroy, id: @study_involvement.id
        end
        include_examples 'unauthorized access: admin controller'
      end
    end
  end

  describe 'authorized access' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
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

      it 'builds study involvement state' do
        expect(assigns(:study_involvement)).not_to be_nil
        expect(assigns(:study_involvement).study_involvement_status).not_to be_nil
      end
    end

    describe 'POST create' do
      describe 'with valid parameters' do
        it 'creates a study_involvement' do
          expect {
            post :create, study_involvement: @params
          }.to change{StudyInvolvement.count}.by(1)
        end

        describe 'creating a study_involvement_status' do
          it 'creates a study_involvement_status with valid params' do
            expect {
              post :create, study_involvement: @params
            }.to change{StudyInvolvementStatus.count}.by(1)
          end

          describe 'when study_involvement_status that has only state (specified by default aasm state) and destroy flag' do
            before(:each) do
              @params[:study_involvement_status_attributes] = { state: StudyInvolvementStatus.aasm.states.sample, _destroy: '0' }
            end

            it 'does not create a study_involvement_status' do
              expect {
                post :create, study_involvement: @params
              }.not_to change{StudyInvolvementStatus.count}
            end

            it 'creates a study_involvement' do
              expect {
                post :create, study_involvement: @params
              }.to change{StudyInvolvement.count}.by(1)
            end

            it 'does not raise an error' do
              post :create, study_involvement: @params
              expect(flash['error']).to be_nil
            end
          end
        end

        it 'redirects to participant page' do
          post :create, study_involvement: @params
          expect(response).to redirect_to(controller: :participants, action: :show, id: @participant.id)
        end
      end

      describe 'with invalid parameters' do
        before(:each) do
          allow_any_instance_of(StudyInvolvement).to receive(:save).and_return(false)
          post :create, study_involvement: @params
        end

        it 'does not create a participant' do
          expect {
            post :create, study_involvement: @params
          }.not_to change{StudyInvolvement.count}
        end

        it 'redirects to new involvement page' do
          expect(response).to redirect_to(controller: :study_involvements, action: :new, participant_id: @participant.id)
        end

        it 'displays error message' do
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

      it 'builds study involvement state if does not exist' do
        expect(assigns(:study_involvement)).not_to be_nil
        expect(assigns(:study_involvement).study_involvement_status).not_to be_nil
      end

      it 'uses study involvement state if available' do
        study_involvement_status = @study_involvement.build_study_involvement_status(name: StudyInvolvementStatus.valid_statuses.sample[:name])
        study_involvement_status.save!
        get :edit, id: @study_involvement.id
        expect(assigns(:study_involvement).study_involvement_status).to eq study_involvement_status
      end
    end

    describe 'POST update' do
      describe 'with valid parameters' do
        it 'redirects to participant page' do
          post :update, id: @study_involvement.id, study_involvement: @params
          expect(response).to redirect_to(controller: :participants, action: :show, id: @participant.id)
        end
      end

      describe 'with invalid parameters' do
        before(:each) do
          allow_any_instance_of(StudyInvolvement).to receive(:save).and_return(false)
          post :update, id: @study_involvement.id, study_involvement: @params
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