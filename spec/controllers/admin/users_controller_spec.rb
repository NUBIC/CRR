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
  end
end
