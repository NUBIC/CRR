require 'spec_helper'

describe Admin::AnswersController do
  before(:each) do
    @survey = FactoryGirl.create( :survey, multiple_section: true)
    @section = @survey.sections.create( title: 'section 1')
    @question = @section.questions.create( text: 'question 1', response_type: 'pick_one')
    @answer = @question.answers.create( text: 'answer 1')
    login_user
    controller.current_user.stub(:has_system_access?).and_return(true)
  end

  describe 'unauthorized user' do
    ['data_manager?','researcher?'].each do |role|
      before(:each) do
        controller.current_user.stub(:admin?).and_return(false)
        all_roles = ['data_manager?','researcher?']
        all_roles.each{|r| r.eql?(role) ? controller.current_user.stub(r.to_sym).and_return(true) : controller.current_user.stub(r.to_sym).and_return(false)}
      end

      it 'should deny access to an attempt to create a answer by an unauthorized user' do
        post :create, { answer: { question_id: @question.id}}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to a billing users  attempt to create a answer by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :create, { answer: { question_id: @question.id}}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an attempt to edit a answer by an unauthorized user' do
        post :edit, { id: @answer.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users  attempt to edit a answer by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :edit, { id: @answer.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end


      it 'should deny access to an attempt to update a answer by an unauthorized user' do
        post :update, { id: @answer.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users attempt to update a answer by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :update, { id: @answer.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an attempt to delete a answer by an unauthorized user' do
        post :destroy, { id: @answer.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users attempt to delete a answer by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :destroy, { id: @answer.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
    end
  end

  describe 'authorized user' do

    before(:each) do
      controller.current_user.stub(:admin?).and_return(true)
    end
    describe 'active survey' do
      before(:each) do
        @answer2 = @question.answers.create( text: 'answer 2')
        @survey.state= 'active'
        @survey.save
        @survey.reload.state.should == 'active'
      end
      it 'should deny access to an attempt to create a answer by an authorized user' do
        post :create, { answer: { question_id: @question.id, title: 'a second answer'}, format: :js}
        @question.reload.answers.size.should ==2
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
      it 'should deny access to edit  a answer by an authorized user' do
        get :edit, { id: @answer.id, format:  :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
      it 'should deny access to update a answer by an authorized user' do
        put :update, { id: @answer.id, answer: { title: 'a second answer'}, format: :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
      it 'should deny access to delete a answer by an authorized user' do
        put :destroy, { id: @answer.id, answer: { title: 'a second answer'}, format: :js}
        @question.answers.size.should == 2
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
    end

    describe 'inactive survey' do
      it 'should allow access to an attempt to create a answer by an authorized user' do
        post :create, { answer: { question_id: @question.id, text: 'a second answer', response_type: 'date'}, format: :js}
        response.should render_template('show')
        @question.reload.answers.size.should == 2
      end
      it 'should allow access to edit  a answer by an authorized user' do
        get :edit, { id: @answer.id, format: :js}
        response.should render_template('edit')
      end
      it 'should allow access to update a answer by an authorized user' do
        put :update, { id: @answer.id, answer: { text: 'a second answer'}, format: :js}
        response.should render_template('show')
        @answer.reload.text.should == 'a second answer'
      end
      it 'should allow access to delete a answer by an authorized user' do
        put :destroy, { id: @answer.id, answer: { title: 'a second answer'}, format: :js}
        response.should render_template('questions/show')
        @question.answers.size.should == 0
      end
    end
    it 'should allow access to view a answer by an authorized user' do
      get :show, { id: @answer.id, format: :js}
      response.should render_template('show')
    end
  end
end
