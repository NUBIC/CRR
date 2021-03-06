require 'rails_helper'

RSpec.describe Admin::SurveysController, type: :controller do
  before(:each) do
    @survey = FactoryBot.create(:survey, multiple_section: false)
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'data manager user' do
    before(:each) do
      allow(controller.current_user).to receive(:data_manager?).and_return(true)
      allow(controller.current_user).to receive(:researcher?).and_return(false)
      allow(controller.current_user).to receive(:admin?).and_return(false)
    end

    it 'should deny access to an attempt by an unauthorized user to create a survey' do
      post :create, params: { survey: { title: 'test'}}
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to edit a survey by an unauthorized user' do
      post :edit, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to update a survey by an unauthorized user' do
      post :update, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to delete a survey by an unauthorized user' do
      post :destroy, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to activate a survey by an unauthorized user' do
      put :activate, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end
    it 'should deny access to an attempt to deactivate a survey by an unauthorized user' do
      put :deactivate, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end
  end

  describe 'resercher', type: :controller do
    before(:each) do
      allow(controller.current_user).to receive(:data_manager?).and_return(false)
      allow(controller.current_user).to receive(:researcher?).and_return(true)
      allow(controller.current_user).to receive(:admin?).and_return(false)
    end

    it 'should deny access to an attempt to create a survey by an unauthorized user' do
      post :create, params: { survey: { title: 'test survey' }}
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to edit a survey by an unauthorized user' do
      post :edit, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to update a survey by an unauthorized user' do
      post :update, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to delete a survey by an unauthorized user' do
      post :destroy, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to activate a survey by an unauthorized user' do
      put :activate, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end

    it 'should deny access to an attempt to deactivate a survey by an unauthorized user' do
      put :deactivate, params: { id: @survey.id }
      expect(response).to redirect_to(controller: :users, action: :dashboard)
      expect(flash['error']).to eq 'Access Denied'
    end
  end

  describe 'authorized user' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
    end

    describe 'active survey' do
      before(:each) do
        @survey.sections.first.questions.create( text: 'question 1', response_type: 'date')
        @survey.state = 'active'
        @survey.save
        expect(@survey.reload.state).to eq 'active'
      end

      it 'should allow access to dectivate a survey by an authorized user' do
        put :deactivate, xhr: true, params: { id: @survey.id }
        expect(response).to redirect_to(controller: :surveys, action: :show)
        expect(@survey.reload.state).to eq 'inactive'
      end

      it 'should deny access to edit  an inactive survey by an authorized user' do
        get :edit, xhr: true, params: { id: @survey.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to update an inactive survey by an authorized user' do
        put :update, xhr: true, params: { id: @survey.id, survey: { title: 'a second survey'}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to delete an inactive survey by an authorized user' do
        expect {
          put :destroy, xhr: true, params: { id: @survey.id }
        }.not_to change{ Survey.count }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'inactive survey' do
      it 'should allow access to an attempt to create a survey by an authorized user' do
        expect {
           post :create, xhr: true, params: { survey: { title: 'a second survey' }}
        }.to change{Survey.count}.by(1)
      expect(response).to redirect_to(controller: :surveys, action: :show, id: Survey.where(title: 'a second survey').last.id)
      end

      it 'should allow access to edit  a survey by an authorized user' do
        get :edit, xhr: true, params: { id: @survey.id }
        expect(response).to render_template('edit')
      end

      it 'should allow access to update a survey by an authorized user' do
        put :update, xhr: true, params: { id: @survey.id, survey: { title: 'a second survey'}}
        expect(response).to redirect_to(controller: :surveys, action: :show, id: @survey.id)
        expect(@survey.reload.title).to eq 'a second survey'
      end

      it 'should allow access to activate a survey by an authorized user' do
        @survey.sections.first.questions.create( text: 'question 1', response_type: 'date')
        expect(@survey.reload.questions.size).to eq 1
        expect(@survey.state).to eq 'inactive'
        put :activate, xhr: true, params: { id: @survey.id }
        expect(response).to redirect_to(controller: :surveys, action: :show, id: @survey.id)
        expect(@survey.reload.state).to eq 'active'
      end

      it 'should allow access to delete a survey by an authorized user' do
        expect {
          put :destroy, xhr: true, params: { id: @survey.id }
        }.to change{ Survey.count }.by(-1)
        expect(response).to redirect_to(controller: :surveys, action: :index)
      end
    end

    it 'should allow access to view a survey by an authorized user' do
      get :show, xhr: true, params: { id: @survey.id }
      expect(response).to render_template('show')
    end

    it 'should allow access to preview a survey by an authorized user' do
      @survey.sections.first.questions.create(text: 'question 1', response_type: 'date')
      @survey.state='active'
      @survey.save
      get :preview, xhr: true, params: { id: @survey.id }
      expect(response).to render_template('admin/surveys/preview')
    end

    it 'should allow access to an attempt to create a survey by an authorized user' do
      expect {
        post :create, xhr: true, params: { survey: { title: 'a second survey' }}
      }.to change{Survey.count}.by(1)
      expect(response).to redirect_to(controller: :surveys, action: :show, id: Survey.where(title: 'a second survey').last.id)
    end
  end
end
