require 'spec_helper'

describe QuestionsController do
  before(:each) do
    @study = FactoryGirl.create(:study)
    @study.update_attribute(:irb_number,'STU00002629')
    @survey = FactoryGirl.create(:survey,:study=>@study,:multiple_section=>true)
    @section = @survey.sections.create(:title=>"section 1")
    @question = @section.questions.create(:text=>"question 1",:response_type=>"short_text")
    login_as("brian")
    controller.current_user.stub(:has_system_access?).and_return(true)
    controller.current_user.should == Aker.authority.find_user("brian")
  end

  describe "unauthorized user" do 
  
    it "should deny access to an attempt to create a question on an unauthorized study" do
      post :create, {:question=>{:section_id=>@section.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to a billing users  attempt to create a question on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :create, {:question=>{:section_id=>@section.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to edit a question on an unauthorized study" do
      post :edit, {:id=>@question.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users  attempt to edit a question on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :edit, {:id=>@question.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to update a question on an unauthorized study" do
      post :update, {:id=>@question.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users attempt to update a question on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :update, {:id=>@question.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to delete a question on an unauthorized study" do
      post :destroy, {:id=>@question.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users attempt to delete a question on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :destroy, {:id=>@question.id}
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
        @survey.state= "active"
        @survey.save
        @survey.reload.state.should == "active"
      end
      it "should deny access to an attempt to create a question on an authorized study" do
        post :create, {:question=>{:section_id=>@section.id,:title=>'a second question'},:format => :js}
        @section.reload.questions.size.should ==1
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to edit  a question on an authorized study" do
        get :edit, {:id=>@question.id,:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to update a question on an authorized study" do
        put :update, {:id=>@question.id,:question=>{:title=>'a second question'},:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to delete a question on an authorized study" do
        put :destroy, {:id=>@question.id,:question=>{:title=>'a second question'},:format => :js}
        @survey.questions.size.should == 1
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
    end

    describe "inactive survey" do 
      it "should allow access to an attempt to create a question on an authorized study" do
        post :create, {:question=>{:section_id=>@section.id,:text=>'a second question',:response_type=>"date"},:format => :js}
        response.should render_template("show")
        @section.reload.questions.size.should == 2
      end
      it "should allow access to edit  a question on an authorized study" do
        get :edit, {:id=>@question.id,:format => :js}
        response.should render_template("edit")
      end
      it "should allow access to update a question on an authorized study" do
        put :update, {:id=>@question.id,:question=>{:text=>'a second question'},:format => :js}
        response.should render_template("show")
        @question.reload.text.should == "a second question"
      end
      it "should allow access to delete a question on an authorized study" do
        put :destroy, {:id=>@question.id,:question=>{:title=>'a second question'},:format => :js}
        response.should render_template("sections/show")
        @survey.questions.size.should == 0
      end
    end
    it "should allow access to view a question on an authorized study" do
      get :show, {:id=>@question.id,:format => :js}
      response.should render_template("show")
    end
  end
end
