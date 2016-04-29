require 'spec_helper'

describe Admin::ConsentsController do
  before(:each) do
    @consent = FactoryGirl.create(:consent)
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
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

      it "should deny access to an attempt by a #{role} to create a consent" do
        post :create, { consent: { content: 'test'}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it "should deny access to an attempt to edit a consent by a #{role}" do
        xhr :post, :edit, { id: @consent.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it "should deny access to an attempt to update a consent by a #{role}" do
        xhr :post, :update, { id: @consent.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it "should deny access to an attempt to delete a consent by a #{role}" do
        post :destroy, { id: @consent.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it "should deny access to an attempt to activate a consent by a #{role}" do
        xhr :put, :activate, { id: @consent.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
      it "should deny access to an attempt to deactivate a consent by a #{role}" do
        xhr :put, :deactivate, { id: @consent.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
    end
  end

  describe 'authorized user' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
    end

    describe 'active consent' do
      before(:each) do
        @consent.state= 'active'
        @consent.save
        expect(@consent.reload.state).to eq 'active'
      end

      it 'should allow access to dectivate a consent by an authorized user' do
        xhr :put, :deactivate, { id: @consent.id }
        expect(response).to redirect_to(controller: :consents, action: :index)
        expect(@consent.reload.state).to eq 'inactive'
      end

      it 'should deny access to edit  an active consent by an authorized user' do
        xhr :get, :edit, { id: @consent.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to update an inactive consent by an authorized user' do
        xhr :put, :update, { id: @consent.id, consent: { title: 'a second consent'}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to delete an inactive consent by an authorized user' do
        put :destroy, { id: @consent.id }
        expect(Consent.all.size).to eq 1
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'inactive consent' do
      it 'should allow access to an attempt to create a consent by an authorized user' do
        post :create, { consent: { content: 'a second consent', consent_type: 'adult'}}
        expect(response).to redirect_to(controller: :consents, action: :index)
        expect(Consent.all.size).to eq 2
      end

      it 'should allow access to edit  a consent by an authorized user' do
        get :edit, { id: @consent.id }
        expect(response).to render_template('edit')
      end

      it 'should allow access to update a consent by an authorized user' do
        put :update, { id: @consent.id, consent: { content: 'a second consent', consent_type: 'adult'}}
        expect(response).to redirect_to(controller: :consents, action: :index)
        expect(@consent.reload.content).to eq 'a second consent'
      end

      it 'should allow access to activate a consent by an authorized user' do
        expect(@consent.state).to eq 'inactive'
        put :activate, { id: @consent.id }
        expect(response).to redirect_to(controller: :consents, action: :index)
        expect(@consent.reload.state).to eq 'active'
      end

      it 'should allow access to delete a consent by an authorized user' do
        put :destroy, { id: @consent.id }
        expect(Consent.all.size).to eq 0
        expect(response).to redirect_to(controller: :consents, action: :index)
      end

      describe 'with signed consent signatures 'do
        before(:each) do
          participant = FactoryGirl.create(:participant)
          consent_signature = FactoryGirl.create(:consent_signature, participant: participant, consent: @consent)
        end

        it 'should deny access to delete a consent' do
          put :destroy, { id: @consent.id }
          expect(Consent.all.size).to eq 1
          expect(response).to redirect_to(controller: :users, action: :dashboard)
          expect(flash['error']).to eq 'Access Denied'
        end

        it 'should deny access to edit consent' do
          get :edit, { id: @consent.id }
          expect(response).to redirect_to(controller: :users, action: :dashboard)
          expect(flash['error']).to eq 'Access Denied'
        end

        it 'should deny access to update consent' do
          xhr :put, :update, { id: @consent.id, consent: { title: 'a second consent'}}
          expect(response).to redirect_to(controller: :users, action: :dashboard)
          expect(flash['error']).to eq 'Access Denied'
        end
      end
    end

    it 'should allow access to view a consent by an authorized user' do
      get :show, { id: @consent.id }
      expect(response).to render_template('show')
    end

    it 'should allow access to an attempt to create a consent by an authorized user' do
      post :create, { consent: { title: 'a second consent'}}
      expect(Consent.all.size).to eq 2
      expect(response).to redirect_to(controller: :consents, action: :index)
    end
  end
end
