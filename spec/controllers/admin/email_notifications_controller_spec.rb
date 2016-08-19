require 'rails_helper'

RSpec.describe Admin::EmailNotificationsController, type: :controller do
  before(:each) do
    Setup.email_notifications
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @email_notification = EmailNotification.first
    @valid_params       = { content: 'hello', state: EmailNotification::STATES.sample }
    @invalid_params     = { content: 'hello', state: 'zzz' }
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
          get :index
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :index
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET show' do
        it 'redirects to dashboard' do
          get :show, id: @email_notification.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :show, id: @email_notification.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'GET edit' do
        it 'redirects to dashboard' do
          get :edit, id: @email_notification.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          get :edit, id: @email_notification.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST update' do
        it 'redirects to dashboard' do
          post :update, id: @email_notification.id, email_notification: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :update, id: @email_notification.id, email_notification: @valid_params
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST deactivate' do
        it 'redirects to dashboard' do
          post :deactivate, id: @email_notification.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :deactivate, id: @email_notification.id
          expect(flash['error']).to eq 'Access Denied'
        end
      end

      describe 'POST activate' do
        it 'redirects to dashboard' do
          post :activate, id: @email_notification.id
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end

        it 'displays "Access Denied" flash message' do
          post :activate, id: @email_notification.id
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
        get :index
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end

      it 'assigns email_notifications' do
        expect(assigns(:email_notifications)).to match_array(EmailNotification.all)
      end
    end

    describe 'GET show' do
      before(:each) do
        get :show, id: @email_notification.id
      end

      it 'renders show template' do
        expect(response).to render_template('show')
      end

      it 'assigns email_notification' do
        expect(assigns(:email_notification)).to eq @email_notification
      end
    end

    describe 'GET edit' do
      before(:each) do
        get :edit, id: @email_notification.id
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns email_notification' do
        expect(assigns(:email_notification)).to eq @email_notification
      end

      it 'deactivates email_notification' do
        expect(assigns(:email_notification)).to be_inactive
      end
    end

    describe 'POST update' do
      describe 'with valid parameters' do
        it 'redirects to email notifications page if email notification is inactive' do
          @email_notification.deactivate
          @email_notification.save
          post :update, id: @email_notification.id, email_notification: @valid_params
          expect(response).to redirect_to(controller: :email_notifications, action: :index)
        end

        it 'redirects to dashboard if email notification is active' do
          post :update, id: @email_notification.id, email_notification: @valid_params
          expect(response).to redirect_to(controller: :users, action: :dashboard)
        end
      end

      describe 'with invalid parameters if email notification is inactive' do
        before(:each) do
          @email_notification.deactivate
          @email_notification.save
          post :update, id: @email_notification.id, email_notification: @invalid_params
        end

        it 'redirects to email notifications page' do
          expect(response).to redirect_to(controller: :email_notifications, action: :index)
        end

        it 'displays error message' do
          expect(flash['error']).not_to be_nil
        end
      end

      it 'it redirects to dashboard if email notification is active and  parameters are invalid' do
        post :update, id: @email_notification.id, email_notification: @valid_params
        expect(response).to redirect_to(controller: :users, action: :dashboard)
      end
    end

    describe 'POST deactivate' do
      before(:each) do
        post :deactivate, id: @email_notification.id
      end

      it 'redirects to email notifications page' do
        expect(response).to redirect_to(controller: :email_notifications, action: :index)
      end

      it 'deactivates email notification' do
        expect(@email_notification.reload).to be_inactive
      end
    end

    describe 'POST activate' do
      before(:each) do
        post :activate, id: @email_notification.id
      end

      it 'redirects to email notifications page' do
        expect(response).to redirect_to(controller: :email_notifications, action: :index)
      end

      it 'activates email notification' do
        expect(@email_notification.reload).to be_active
      end
    end
  end
end