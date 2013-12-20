require 'spec_helper'

describe Admin::StudiesController do
  before(:each) do
    @study = FactoryGirl.create(:study)
    login_as("brian")
    controller.current_user.stub(:has_system_access?).and_return(true)
    controller.current_user.should == Aker.authority.find_user("brian")
  end

  describe "unauthorized access" do 

    ["data_manager?","researcher?"].each do |role|
      before(:each) do 
        controller.current_user.stub(:admin?).and_return(false)
        all_roles = ["data_manager?","researcher?"]
        all_roles.each{|r| r.eql?(role) ? controller.current_user.stub(r.to_sym).and_return(true) : controller.current_user.stub(r.to_sym).and_return(false)}
      end
  
      it "should deny access to an attempt by a #{role} to create a study" do
        post :create, {:study=>{:name=>"test"}}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end


      it "should deny access to an attempt to edit a study by a #{role}" do
        post :edit, {:id=>@study.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end


      it "should deny access to an attempt to update a study by a #{role}" do
        post :update, {:id=>@study.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end

      it "should deny access to an attempt to delete a study by a #{role}" do
        post :destroy, {:id=>@study.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end

      it "should deny access to an attempt to activate a study by a #{role}" do
        put :activate, {:id=>@study.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to an attempt to deactivate a study by a #{role}" do
        put :deactivate, {:id=>@study.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
    end
  end

  describe "authorized user" do 

    before(:each) do 
      controller.current_user.stub(:admin?).and_return(true)
    end
    it "should allow access to an attempt to create a study by an authorized user" do
      post :create, {:study=>{:name=>'a second study',:irb_number=>"12345"}}
      response.should redirect_to(admin_studies_path)
      Study.all.size.should == 2
    end
    it "should allow access to edit  a study by an authorized user" do
      get :edit, {:id=>@study.id}
      response.should render_template("edit")
    end
    it "should allow access to update a study by an authorized user" do
      put :update, {:id=>@study.id,:study=>{:name=>'a second study'}}
      response.should redirect_to(admin_study_path(@study))
      @study.reload.name.should == "a second study"
    end
    it "should allow access to activate a study by an authorized user" do
      @study.state.should == "inactive"
      put :activate, {:id=>@study.id}
      response.should redirect_to(admin_studies_path)
      @study.reload.state.should == "active"
    end
    it "should allow access to deactivate a study by an authorized user" do
      @study.state ="active"
      @study.save
      @study.state.should == "active"
      put :deactivate, {:id=>@study.id}
      response.should redirect_to(admin_studies_path)
      @study.reload.state.should == "inactive"
    end
    it "should allow access to delete a study by an authorized user" do
      put :destroy, {:id=>@study.id}
      Study.all.size.should ==0 
      response.should redirect_to(admin_studies_path)
    end
  end
end
