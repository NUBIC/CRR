require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  setup :activate_authlogic
  let(:valid_attributes) { { email: 'test@test.com', current_password: '12345678', password: '12345678', password_confirmation: '12345678' } }
  let(:invalid_attributes) { { email: 'test', password: '12345678', password_confirmation: '12345678' } }

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Account' do
        expect {
          post :create, {account: valid_attributes}
        }.to change(Account, :count).by(1)
      end

      it 'sends welcome email if available' do
        Setup.email_notifications
        expect {
          post :create, {account: valid_attributes}
        }.to change(ActionMailer::Base.deliveries,:size).by(1)
      end

      it 'sends admin notification email if welcome email is not available' do
        expect {
          post :create, { account: valid_attributes }
        }.to change(ActionMailer::Base.deliveries,:size).by(1)
      end

      it 'sends admin notification email if welcome email is deactivated' do
        Setup.email_notifications
        email_notification = EmailNotification.active.welcome_participant
        email_notification.deactivate
        email_notification.save
        expect {
          post :create, {account: valid_attributes}
        }.to change(ActionMailer::Base.deliveries,:size).by(1)
      end

      it 'assigns a newly created account as @account' do
        post :create, { account: valid_attributes }
        expect(assigns(:account)).to be_a(Account)
        # expect(assigns(:account)).to be_persisted
      end

      it 'redirects to the dashboard page' do
        post :create, {account: valid_attributes}
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved account as @account' do
        post :create, {account: invalid_attributes}
        expect(assigns(:account)).to be_a_new(Account)
      end

      it 're-renders the \'new\' template' do
        post :create, {account: invalid_attributes}
        expect(response).to redirect_to('/user_login#sign_up')
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
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end
    end

    describe 'authorized access' do
      it 'renders edit page' do
        get :edit, {id: account.id}
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PUT update' do
    let(:account) { FactoryGirl.create(:account) }
    describe 'with valid params' do
      it 'updates the requested account' do
        put :update, { id: account.id, account: valid_attributes }
      end

      it 'assigns the requested account as @account' do
        put :update, {id: account.id, account: valid_attributes}
        expect(assigns(:account)).to eq(account)
      end

      it 'redirects to the dashboard page' do
        put :update, {id: account.id, account: valid_attributes}
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
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

    describe 'password', type: :controller do
      it 'with invalid current password generates flash error' do
        put :update, {id: account.id, account: { email: 'test@test.com', current_password: '12345679' } }
        expect(flash['error']).to eq 'Current password doesn\'t match. Please try again.'
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
        expect(response).to redirect_to(controller: :accounts, action: :dashboard)
      end
    end
  end

  describe 'GET dashboard' do
    let(:account) { FactoryGirl.create(:account) }

    it 'deletes inactive participants' do
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

  describe 'POST express_sign_up' do
    describe 'with valid email contact params' do
      let(:valid_express_signup_attributes) {{ name: 'Joe', contact: 'email', email: 'joe@doe.com'}}

      describe 'when corresponding EmailNotification is available' do
        before :each do
          Setup.email_notifications
        end

        it 'sends welcome email and admin email when corresponding EmailNotification is available' do
          expect {
            post :express_sign_up, valid_express_signup_attributes
          }.to change(ActionMailer::Base.deliveries,:size).by(2)
        end

        it 'generates proper notification message' do
          post :express_sign_up, valid_express_signup_attributes
          expect(flash['notice']).to eq 'Thank you for your interest in the Communication Research Registry. We have sent a reminder to your email address.'
        end
      end

      describe 'when corresponding EmailNotification is deactivated' do
        before :each do
          Setup.email_notifications
          express_sign_up_email = EmailNotification.active.express_sign_up
          express_sign_up_email.deactivate
          express_sign_up_email.save!
        end

        it 'sends admin email' do
          expect {
            post :express_sign_up, valid_express_signup_attributes
          }.to change(ActionMailer::Base.deliveries,:size).by(1)
        end

        it 'generates proper notification message' do
          post :express_sign_up, valid_express_signup_attributes
          expect(flash['notice']).to eq 'Thank you for your interest in the Communication Research Registry. We will send a reminder to your email address.'
        end
      end

      describe 'when corresponding EmailNotification is not set' do
        it 'sends admin email' do
          expect {
            post :express_sign_up, valid_express_signup_attributes
          }.to change(ActionMailer::Base.deliveries,:size).by(1)
        end

        it 'generates proper notification message' do
          post :express_sign_up, valid_express_signup_attributes
          expect(flash['notice']).to eq 'Thank you for your interest in the Communication Research Registry. We will send a reminder to your email address.'
        end
      end

      it 'redirects to the dashboard page' do
        post :express_sign_up, valid_express_signup_attributes
        expect(response).to redirect_to('/user_login#express_sign_up')
      end
    end

    describe 'with valid phone contact params' do
      let(:valid_express_signup_attributes) {{ name: 'Joe', contact: 'phone', phone: '123-456-7891'}}

      it 'sends admin email' do
        expect {
          post :express_sign_up, valid_express_signup_attributes
        }.to change(ActionMailer::Base.deliveries,:size).by(1)
      end

      it 'redirects to the dashboard page' do
        post :express_sign_up, valid_express_signup_attributes
        expect(response).to redirect_to('/user_login#express_sign_up')
      end

      it 'generates proper notification message' do
        post :express_sign_up, valid_express_signup_attributes
        expect(flash['notice']).to eq 'Thank you for your interest in the Communication Research Registry. We will call you within two business days.'
      end
    end

    describe 'with invalid params' do
      let(:invalid_express_signup_attributes) {{ name: 'Joe' }}

      it 're-renders the \'express_sign_up\' template' do
        post :express_sign_up, invalid_express_signup_attributes
        expect(response).to redirect_to("/user_login?name=Joe#express_sign_up")
      end

      it 'keeps entered parameters' do
        post :express_sign_up, invalid_express_signup_attributes
        expect(controller.params[:name]).to eq invalid_express_signup_attributes[:name]
      end
    end
  end
end
