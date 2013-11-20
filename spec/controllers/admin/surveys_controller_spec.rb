require 'spec_helper'

describe Admin::SurveysController do
  before(:each) do
    @survey = FactoryGirl.create(:survey,:multiple_section=>false)
    login_as("brian")
    controller.current_user.stub(:has_system_access?).and_return(true)
    controller.current_user.should == Aker.authority.find_user("brian")
  end

  describe "data manager user" do 
    before(:each) do 
      controller.current_user.stub(:data_manager?).and_return(true)
      controller.current_user.stub(:researcher?).and_return(false)
      controller.current_user.stub(:admin?).and_return(false)
    end
  
    it "should deny access to an attempt by an unauthorized user to create a survey" do
      post :create, {:survey=>{:title=>"test"}}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to edit a survey by an unauthorized user" do
      post :edit, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to update a survey by an unauthorized user" do
      post :update, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to delete a survey by an unauthorized user" do
      post :destroy, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to activate a survey by an unauthorized user" do
      put :activate, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end
    it "should deny access to an attempt to deactivate a survey by an unauthorized user" do
      put :deactivate, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end
  end

  describe "resercher" do 
    before(:each) do 
      controller.current_user.stub(:data_manager?).and_return(false)
      controller.current_user.stub(:researcher?).and_return(true)
      controller.current_user.stub(:admin?).and_return(false)
    end
  
    it "should deny access to an attempt to create a survey by an unauthorized user" do
      post :create, {:survey=>{:title=>"test survey"}}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to edit a survey by an unauthorized user" do
      post :edit, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to update a survey by an unauthorized user" do
      post :update, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to delete a survey by an unauthorized user" do
      post :destroy, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to activate a survey by an unauthorized user" do
      put :activate, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end
    it "should deny access to an attempt to deactivate a survey by an unauthorized user" do
      put :deactivate, {:id=>@survey.id}
      response.should redirect_to(admin_default_path)
      flash[:notice].should == "Access Denied"
    end
  end

  describe "authorized user" do 

    before(:each) do 
      controller.current_user.stub(:admin?).and_return(true)
    end
    describe "active survey" do 
      before(:each) do 
        @survey.sections.first.questions.create(:text=>"question 1",:response_type=>'date')
        @survey.state= "active"
        @survey.save
        @survey.reload.state.should == "active"
      end

      it "should allow access to dectivate a survey by an authorized user" do
        put :deactivate, {:id=>@survey.id,:format => :js}
        response.should render_template("show")
        @survey.reload.state.should == "inactive"
      end
      it "should deny access to edit  an inactive survey by an authorized user" do
        get :edit, {:id=>@survey.id,:format => :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to update an inactive survey by an authorized user" do
        put :update, {:id=>@survey.id,:survey=>{:title=>'a second survey'},:format => :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to delete an inactive survey by an authorized user" do
        put :destroy, {:id=>@survey.id,:format => :js}
        Survey.all.size.should ==1
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
    end
    describe "inactive survey" do 

      it "should allow access to an attempt to create a survey by an authorized user" do
        post :create, {:survey=>{:title=>'a second survey'},:format => :js}
        response.should render_template("show")
        Survey.all.size.should == 2
      end
      it "should allow access to edit  a survey by an authorized user" do
        get :edit, {:id=>@survey.id,:format => :js}
        response.should render_template("edit")
      end
      it "should allow access to update a survey by an authorized user" do
        put :update, {:id=>@survey.id,:survey=>{:title=>'a second survey'},:format => :js}
        response.should render_template("admin/surveys/show")
        @survey.reload.title.should == "a second survey"
      end
      it "should allow access to activate a survey by an authorized user" do
        @survey.sections.first.questions.create(:text=>"question 1",:response_type=>'date')
        @survey.reload.questions.size.should == 1
        @survey.state.should == "inactive"
        put :activate, {:id=>@survey.id,:format => :js}
        response.should render_template("show")
        @survey.reload.state.should == "active"
      end
      it "should allow access to delete a survey by an authorized user" do
        put :destroy, {:id=>@survey.id,:format => :js}
        Survey.all.size.should ==0 
        response.should render_template("index")
      end
    end
    it "should allow access to view a survey by an authorized user" do
      get :show, {:id=>@survey.id,:format => :js}
      response.should render_template("show")
    end
    it "should allow access to preview a survey by an authorized user" do
      @survey.sections.first.questions.create(:text=>"question 1",:response_type=>'date')
      @survey.state="active"
      @survey.save
      get :preview, {:id=>@survey.id,:format => :js}
      response.should render_template("admin/surveys/preview")
    end
    it "should allow access to an attempt to create a survey by an authorized user" do
      post :create, {:survey=>{:title=>'a second survey'},:format => :js}
      Survey.all.size.should ==2
      response.should render_template("admin/surveys/show")
    end
  end
end
