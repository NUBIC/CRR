require 'rails_helper'

RSpec.describe Admin::StudiesController, type: :controller do
  before(:each) do
    @study = FactoryGirl.create(:study)
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized access' do
    ['data_manager?', 'researcher?'].each do |role|
      before(:each) do
        all_roles = ['data_manager?', 'researcher?']
        all_roles.each do |r|
          if r.eql?(role)
            allow(controller.current_user).to receive(r.to_sym).and_return(true)
          else
            allow(controller.current_user).to receive(r.to_sym).and_return(false)
          end
        end
      end

      it 'should deny access to an attempt by a #{role} to create a study' do
        post :create, { study: { name: 'test'}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to edit a study by a #{role}' do
        post :edit, { id: @study.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to update a study by a #{role}' do
        post :update, { id: @study.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to delete a study by a #{role}' do
        post :destroy, { id: @study.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to activate a study by a #{role}' do
        put :activate, { id: @study.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to deactivate a study by a #{role}' do
        put :deactivate, { id: @study.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
    end
  end

  describe 'authorized user' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
    end

    it 'should allow access to an attempt to create a study by an authorized user' do
      expect {
        post :create, { study: { name: 'a second study', irb_number: '12345'}}
      }.to change{Study.count}.by(1)
      expect(response).to redirect_to(controller: :studies, action: :index)
    end

    it 'should allow access to edit  a study by an authorized user' do
      get :edit, { id: @study.id }
      expect(response).to render_template('edit')
    end

    it 'should allow access to update a study by an authorized user' do
      put :update, { id: @study.id, study: { name: 'a second study' }}
      expect(response).to redirect_to(controller: :studies, action: :show, id: @study.id)
      expect(@study.reload.name).to eq 'a second study'
    end

    it 'should allow access to activate a study by an authorized user' do
      expect(@study.state).to eq 'inactive'
      put :activate, { id: @study.id }
      expect(response).to redirect_to(controller: :studies, action: :index)
      expect(@study.reload.state).to eq 'active'
    end

    it 'should allow access to deactivate a study by an authorized user' do
      @study.state ='active'
      @study.save
      expect(@study.state).to eq 'active'
      put :deactivate, { id: @study.id }
      expect(response).to redirect_to(controller: :studies, action: :index)
      expect(@study.reload.state).to eq 'inactive'
    end

    it 'should allow access to delete a study by an authorized user' do
      expect {
        put :destroy, { id: @study.id }
      }.to change{ Study.count }.by(-1)
      expect(response).to redirect_to(controller: :studies, action: :index)
    end
  end
end
