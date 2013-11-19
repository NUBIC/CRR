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
    end
  
    it "should deny access to an attempt to create a survey on an unauthorized study" do
      post :create, {:survey=>{:study_id=>@study.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to edit a survey on an unauthorized study" do
      post :edit, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to update a survey on an unauthorized study" do
      post :update, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to delete a survey on an unauthorized study" do
      post :destroy, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to activate a survey on an unauthorized study" do
      put :activate, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end
    it "should deny access to an attempt to deactivate a survey on an unauthorized study" do
      put :deactivate, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end
  end

  describe "resercher" do 
    before(:each) do 
      controller.current_user.stub(:reseacher?).and_return(true)
    end
  
    it "should deny access to an attempt to create a survey on an unauthorized study" do
      post :create, {:survey=>{:study_id=>@study.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to edit a survey on an unauthorized study" do
      post :edit, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to update a survey on an unauthorized study" do
      post :update, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to delete a survey on an unauthorized study" do
      post :destroy, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to activate a survey on an unauthorized study" do
      put :activate, {:id=>@survey.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end
    it "should deny access to an attempt to deactivate a survey on an unauthorized study" do
      put :deactivate, {:id=>@survey.id}
      response.should redirect_to(default_path)
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

      it "should allow access to dectivate a survey on an authorized study" do
        put :deactivate, {:id=>@survey.id,:format => :js}
        response.should render_template("show")
        @survey.reload.state.should == "inactive"
      end
      it "should deny access to edit  an inactive survey on an authorized study" do
        get :edit, {:id=>@survey.id,:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to update an inactive survey on an authorized study" do
        put :update, {:id=>@survey.id,:survey=>{:title=>'a second survey'},:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to delete an inactive survey on an authorized study" do
        put :destroy, {:id=>@survey.id,:format => :js}
        @study.reload.surveys.size.should ==1
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
    end
    describe "inactive survey" do 

      it "should allow access to an attempt to create a survey on an authorized study" do
        post :create, {:survey=>{:study_id=>@study.id,:title=>'a second survey'},:format => :js}
        response.should render_template("show")
        @study.reload.surveys.size.should == 2
      end
      it "should allow access to edit  a survey on an authorized study" do
        get :edit, {:id=>@survey.id,:format => :js}
        response.should render_template("edit")
      end
      it "should allow access to update a survey on an authorized study" do
        put :update, {:id=>@survey.id,:survey=>{:title=>'a second survey'},:format => :js}
        response.should render_template("show")
        @survey.reload.title.should == "a second survey"
      end
      it "should allow access to activate a survey on an authorized study" do
        @survey.sections.first.questions.create(:text=>"question 1",:response_type=>'date')
        @survey.reload.questions.size.should == 1
        @survey.state.should == "inactive"
        put :activate, {:id=>@survey.id,:format => :js}
        response.should render_template("show")
        @survey.reload.state.should == "active"
      end
      it "should allow access to delete a survey on an authorized study" do
        put :destroy, {:id=>@survey.id,:format => :js}
        @study.reload.surveys.size.should ==0 
        response.should render_template("index")
      end
    end
    it "should allow access to view a survey on an authorized study" do
      get :show, {:id=>@survey.id,:format => :js}
      response.should render_template("show")
    end
    it "should allow access to preview a survey on an authorized study" do
      @survey.sections.first.questions.create(:text=>"question 1",:response_type=>'date')
      @survey.state="active"
      @survey.save
      get :preview, {:id=>@survey.id,:format => :js}
      response.should render_template("preview")
    end
    it "should allo access to an attempt to create a survey on an authorized study" do
      post :create, {:survey=>{:study_id=>@study.id,:title=>'a second survey'},:format => :js}
      @study.reload.surveys.size.should ==2
      response.should render_template("show")
    end
  end
end
