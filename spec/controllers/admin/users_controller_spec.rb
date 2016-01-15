require 'spec_helper'

describe Admin::UsersController do
  before(:each) do
    @user = FactoryGirl.create(:user, netid: 'test_user')
    login_user
    controller.current_user.stub(:has_system_access?).and_return(true)
  end

  describe 'unauthorized access' do
    ['data_manager?','researcher?'].each do |role|
      before(:each) do
        controller.current_user.stub(:admin?).and_return(false)
        all_roles = ['data_manager?', 'researcher?']
        all_roles.each{|r| r.eql?(role) ? controller.current_user.stub(r.to_sym).and_return(true) : controller.current_user.stub(r.to_sym).and_return(false)}
      end

      it "should deny access to an attempt by a #{role} to create a user" do
        post :create, { user: { netid: 'test_user' } }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it "should deny access to an attempt to edit a user by a #{role}" do
        post :edit, { id: @user.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it "should deny access to an attempt to update a user by a #{role}" do
        post :update, { id: @user.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it "should deny access to an attempt to delete a user by a #{role}" do
        post :destroy, { id: @user.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
    end
  end

  describe 'authorized user' do
    before(:each) do
      controller.current_user.stub(:admin?).and_return(true)
    end

    it 'should allow access to an attempt to create a user by an authorized user' do
      post :create, { user: { netid: 'test_user' } }
      response.should redirect_to(admin_users_path)
      User.all.size.should == 2
    end

    it 'should allow access to edit a user by an authorized user' do
      get :edit, { id: @user.id }
      response.should render_template('edit')
    end

    it 'should allow access to update a user by an authorized user' do
      put :update, {id: @user.id, user: { data_manager: true } }
      response.should redirect_to(admin_users_path)
      @user.reload.data_manager.should == true
    end

    it 'should allow access to delete a user by an authorized user' do
      put :destroy, { id: @user.id }
      User.all.size.should == 0
      response.should redirect_to(admin_users_path)
    end

    it "should notify user of if email reminder is available" do
      expect { post :create, { user: { netid: 'test_user', researcher: true  } } }.not_to change(ActionMailer::Base.deliveries,:size)
      expect(flash[:error]).to eq 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated)'
    end

    it "should notify researcher of created account if email reminder is available" do
      FactoryGirl.create(:email_notification, email_type: EmailNotification::WELCOME_RESEARCHER)
      expect { post :create, { user: { netid: 'test_user', researcher: true  } } }.to change(ActionMailer::Base.deliveries,:size).by(1)
    end

    it "should not notify data manager of created account" do
      expect { post :create, { user: { netid: 'test_user', data_manager: true  } } }.not_to change(ActionMailer::Base.deliveries,:size)
    end

    it "should not notify admin of created account" do
      expect { post :create, { user: { netid: 'test_user', admin: true  } } }.not_to change(ActionMailer::Base.deliveries,:size)
    end

    it "should not notify regular user of created account" do
      expect { post :create, { user: { netid: 'test_user' } } }.not_to change(ActionMailer::Base.deliveries,:size)
    end

  end
end
