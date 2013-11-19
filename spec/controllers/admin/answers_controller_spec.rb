require 'spec_helper'

describe AnswersController do
  before(:each) do
    @study = FactoryGirl.create(:study)
    @study.update_attribute(:irb_number,'STU00002629')
    @survey = FactoryGirl.create(:survey,:study=>@study,:multiple_section=>true)
    @section = @survey.sections.create(:title=>"section 1")
    @question = @section.questions.create(:text=>"question 1",:response_type=>"pick_one")
    @answer = @question.answers.create(:text=>"answer 1")
    login_as("brian")
    controller.current_user.stub(:has_system_access?).and_return(true)
    controller.current_user.should == Aker.authority.find_user("brian")
  end

  describe "unauthorized user" do 
  
    it "should deny access to an attempt to create a answer on an unauthorized study" do
      post :create, {:answer=>{:question_id=>@question.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to a billing users  attempt to create a answer on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :create, {:answer=>{:question_id=>@question.id}}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to edit a answer on an unauthorized study" do
      post :edit, {:id=>@answer.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users  attempt to edit a answer on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :edit, {:id=>@answer.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end


    it "should deny access to an attempt to update a answer on an unauthorized study" do
      post :update, {:id=>@answer.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users attempt to update a answer on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :update, {:id=>@answer.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an attempt to delete a answer on an unauthorized study" do
      post :destroy, {:id=>@answer.id}
      response.should redirect_to(default_path)
      flash[:notice].should == "Access Denied"
    end

    it "should deny access to an billing users attempt to delete a answer on an unauthorized study" do
      controller.current_user.stub(:billing?).and_return(true)
      post :destroy, {:id=>@answer.id}
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
        @answer2 = @question.answers.create(:text=>"answer 2")
        @survey.state= "active"
        @survey.save
        @survey.reload.state.should == "active"
      end
      it "should deny access to an attempt to create a answer on an authorized study" do
        post :create, {:answer=>{:question_id=>@question.id,:title=>'a second answer'},:format => :js}
        @question.reload.answers.size.should ==2
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to edit  a answer on an authorized study" do
        get :edit, {:id=>@answer.id,:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to update a answer on an authorized study" do
        put :update, {:id=>@answer.id,:answer=>{:title=>'a second answer'},:format => :js}
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to delete a answer on an authorized study" do
        put :destroy, {:id=>@answer.id,:answer=>{:title=>'a second answer'},:format => :js}
        @question.answers.size.should == 2
        response.should redirect_to(default_path)
        flash[:notice].should == "Access Denied"
      end
    end

    describe "inactive survey" do 
      it "should allow access to an attempt to create a answer on an authorized study" do
        post :create, {:answer=>{:question_id=>@question.id,:text=>'a second answer',:response_type=>"date"},:format => :js}
        response.should render_template("show")
        @question.reload.answers.size.should == 2
      end
      it "should allow access to edit  a answer on an authorized study" do
        get :edit, {:id=>@answer.id,:format => :js}
        response.should render_template("edit")
      end
      it "should allow access to update a answer on an authorized study" do
        put :update, {:id=>@answer.id,:answer=>{:text=>'a second answer'},:format => :js}
        response.should render_template("show")
        @answer.reload.text.should == "a second answer"
      end
      it "should allow access to delete a answer on an authorized study" do
        put :destroy, {:id=>@answer.id,:answer=>{:title=>'a second answer'},:format => :js}
        response.should render_template("questions/show")
        @question.answers.size.should == 0
      end
    end
    it "should allow access to view a answer on an authorized study" do
      get :show, {:id=>@answer.id,:format => :js}
      response.should render_template("show")
    end
  end
end
