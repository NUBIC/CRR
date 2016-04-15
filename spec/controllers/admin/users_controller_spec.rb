require 'spec_helper'

describe Admin::UsersController do
  before(:each) do
    @user = FactoryGirl.create(:user, netid: 'test_user')
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized access' do
    ['data_manager?', 'researcher?'].each do |role|
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

      it 'should deny access to an attempt by a #{role} to create a user' do
        expect {
          post :create, { user: { netid: 'test_user' } }
        }.not_to change{ User.count }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to edit a user by a #{role}' do
        post :edit, { id: @user.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to update a user by a #{role}' do
        post :update, { id: @user.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to delete a user by a #{role}' do
        expect {
          put :destroy, { id: @user.id }
        }.not_to change{ User.count }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end
    end
  end

  describe 'authorized user' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
    end

    it 'should allow access to an attempt to create a user by an authorized user' do
      expect {
        post :create, { user: { netid: 'test_user' } }
      }.to change{ User.count }.by(1)
      expect(response).to redirect_to(controller: :users, action: :index)
    end

    it 'should allow access to edit a user by an authorized user' do
      get :edit, { id: @user.id }
      expect(response).to render_template('edit')
    end

    it 'should allow access to update a user by an authorized user' do
      put :update, {id: @user.id, user: { data_manager: true } }
      expect(response).to redirect_to(controller: :users, action: :index)
      expect(@user.reload.data_manager).to eq true
    end

    it 'should allow access to delete a user by an authorized user' do
      expect {
        put :destroy, { id: @user.id }
      }.to change{ User.count }.by(-1)
      expect(response).to redirect_to(controller: :users, action: :index)
    end

    it 'should notify user if email reminder is not available' do
      welcome_email = EmailNotification.active.welcome_researcher
      welcome_email.deactivate
      welcome_email.save!
      expect { post :create, { user: { netid: 'test_user', researcher: true  } } }.not_to change(ActionMailer::Base.deliveries, :size)
      expect(flash['error']).to eq 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated)'
    end

    it 'should notify researcher of created account if email reminder is available' do
      expect { post :create, { user: { netid: 'test_user', researcher: true  } } }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it 'should not notify data manager of created account' do
      expect { post :create, { user: { netid: 'test_user', data_manager: true  } } }.not_to change(ActionMailer::Base.deliveries, :size)
    end

    it 'should not notify admin of created account' do
      expect { post :create, { user: { netid: 'test_user', admin: true  } } }.not_to change(ActionMailer::Base.deliveries, :size)
    end

    it 'should not notify regular user of created account' do
      expect { post :create, { user: { netid: 'test_user' } } }.not_to change(ActionMailer::Base.deliveries, :size)
    end
  end
end
