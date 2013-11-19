require 'spec_helper'

describe SectionsController do
  before(:each) do
    @study = FactoryGirl.create(:study)
    @study.update_attribute(:irb_number,'STU00002629')
    @survey = FactoryGirl.create(:survey,:study=>@study,:multiple_section=>true)
    @section = @survey.sections.create(:title=>"section 1")
    login_as("brian")
    controller.current_user.stub(:has_system_access?).and_return(true)
    controller.current_user.should == Aker.authority.find_user("brian")
  end

  describe "unauthorized user" do 
  
    it "should deny access to an attempt to create a section on an unauthorized study" do
      post :create, {:section=>{:survey_id=>@survey.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to a billing users  attempt to create a section on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :create, {:section=>{:survey_id=>@survey.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to edit a section on an unauthorized study" do
      post :edit, {:id=>@section.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users  attempt to edit a section on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :edit, {:id=>@section.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to update a section on an unauthorized study" do
      post :update, {:id=>@section.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users attempt to update a section on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :update, {:id=>@section.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to delete a section on an unauthorized study" do
      post :destroy, {:id=>@section.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users attempt to delete a section on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :destroy, {:id=>@section.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end
  end

  describe "authorized user" do 

    before(:each) do 
      @role = FactoryGirl.create(:role, :study => @study, :netid => 'brian') 
    end
    describe "active survey" do 
      before(:each) do 
        @survey.sections.first.questions.create(:text=>"question 1",:response_type=>'date')
        @survey.state= "active"
        @survey.save
        @survey.reload.state.should == "active"
      end
      it "should deny access to an attempt to create a section on an authorized study" do
        post :create, {:section=>{:survey_id=>@survey.id,:title=>'a second section'},:format => :js}
        @survey.reload.sections.size.should ==1
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to edit  a section on an authorized study" do
        get :edit, {:id=>@section.id,:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to update a section on an authorized study" do
        put :update, {:id=>@section.id,:section=>{:title=>'a second section'},:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to delete a section on an authorized study" do
        put :destroy, {:id=>@section.id,:section=>{:title=>'a second section'},:format => :js}
        @survey.sections.size.should == 1
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
    end

    describe "inactive survey" do 
      it "should allow access to an attempt to create a section on an authorized study" do
        post :create, {:section=>{:survey_id=>@survey.id,:title=>'a second section'},:format => :js}
        response.should render_template("show")
        @survey.reload.sections.size.should == 2
      end
      it "should allow access to edit  a section on an authorized study" do
        get :edit, {:id=>@section.id,:format => :js}
        response.should render_template("edit")
      end
      it "should allow access to update a section on an authorized study" do
        put :update, {:id=>@section.id,:section=>{:title=>'a second section'},:format => :js}
        response.should render_template("show")
        @section.reload.title.should == "a second section"
      end
      it "should allow access to delete a section on an authorized study" do
        put :destroy, {:id=>@section.id,:section=>{:title=>'a second section'},:format => :js}
        response.should render_template("surveys/show")
        @survey.sections.size.should == 0
      end
    end
    it "should allow access to view a section on an authorized study" do
      get :show, {:id=>@section.id,:format => :js}
      response.should render_template("show")
    end
  end
end
