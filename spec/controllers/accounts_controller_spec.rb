require 'spec_helper'

describe AccountsController do
  setup :activate_authlogic
  let(:valid_attributes) { { email: 'test@test.com', current_password: '1234', password: '1234', password_confirmation: '1234' } }
  let(:invalid_attributes) { { email: 'test', password: '1234', password_confirmation: '1234' } }

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Account' do
        expect {
          post :create, {account: valid_attributes}
        }.to change(Account, :count).by(1)
      end

      it 'sends welcome email' do
        welcome_email = FactoryGirl.create(:email_notification)
        expect {
          post :create, {account: valid_attributes}
        }.to change(ActionMailer::Base.deliveries,:size).by(1)
      end

      it 'assigns a newly created account as @account' do
        post :create, {account: valid_attributes}
        expect(assigns(:account)).to be_a(Account)
        expect(assigns(:account)).to be_persisted
      end

      it 'redirects to the dashboard page' do
        post :create, {:account => valid_attributes}
        expect(response).to redirect_to dashboard_path
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved account as @account' do
        post :create, {account: invalid_attributes}
        expect(assigns(:account)).to be_a_new(Account)
      end

      it 're-renders the \'new\' template' do
        post :create, {account: invalid_attributes}
        expect(response).to redirect_to(public_login_path(anchor: 'sign_up'))
      end
    end
  end

  describe 'PUT update' do
    let(:account) { FactoryGirl.create(:account) }
    describe 'with valid params' do
      it 'updates the requested account' do
        put :update, {id: account.id, account: valid_attributes}
      end

      it 'assigns the requested account as @account' do
        put :update, {id: account.id, account: valid_attributes}
        expect(assigns(:account)).to eq(account)
      end

      it 'redirects to the dashboard page' do
        put :update, {id: account.id, account: valid_attributes}
        expect(response).to redirect_to dashboard_path
      end
    end

    describe 'with invalid params' do
      it 'assigns the account as @account' do
        put :update, {id: account.id, account: invalid_attributes}
        expect(assigns(:account)).to eq(account)
      end

      it 're-renders the \'edit\' template' do
        put :update, {id: account.id, account: invalid_attributes}
        expect(response).to render_template('edit')
      end
    end

    describe 'password' do
      it 'with invalid current password generates flash error' do
        put :update, {id: account.id, account: { email: 'test@test.com', current_password: '12345' } }
        flash[:error].should == 'Current password doesn\'t match. Please try again.'
      end

      it 're-renders the \'edit\' template' do
        put :update, {id: account.id, account: invalid_attributes}
        expect(response).to render_template('edit')
      end
    end

    describe 'unauthorized access' do
      let(:other_account) { FactoryGirl.create(:account, email: 'test1@test.com') }
      it 'redirects to logout page if user is logged in and tried to update other user\'s account' do
        AccountSession.create(other_account)
        put :update, {id: account.id, account: valid_attributes}
        expect(response).to redirect_to dashboard_path
      end
    end
  end

  describe 'GET dahboard' do
    let(:account) { FactoryGirl.create(:account) }

    it 'deletes inactive participants' do
      controller.stub(:current_user).and_return(account)

      Participant.aasm.states.map(&:name).each do |state|
        account.participants << FactoryGirl.create(:participant, state: state)
      end

      expect(account.participants.length).to eq Participant.aasm.states.length
      get :dashboard
      expect(response).to render_template('dashboard')
      expect(account.participants.reload.length).to be < Participant.aasm.states.length
      [:new, :consent, :demographics, :consent_denied].each do |state|
        expect(account.participants.where(state: state.to_s)).to be_empty
      end
    end
  end

  describe 'GET edit' do
    let(:account) { FactoryGirl.create(:account) }

    describe 'unauthorized access' do
      let(:other_account) { FactoryGirl.create(:account, email: 'test1@test.com') }
      it 'redirects to dashboard page if user is logged in and tried to edit other user\'s account' do
        AccountSession.create(other_account)
        get :edit, {id: account.id}
        expect(response).to redirect_to dashboard_path
      end
    end

    describe 'authorized access' do
      it 'renders edit page' do
        get :edit, {id: account.id}
        expect(response).to render_template('edit')
      end
    end
  end
end
