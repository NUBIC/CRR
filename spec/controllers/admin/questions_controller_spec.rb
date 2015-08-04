require 'spec_helper'

describe Admin::QuestionsController do
  before(:each) do
    @survey = FactoryGirl.create( :survey, multiple_section: true)
    @section = @survey.sections.create( title: 'section 1')
    @question = @section.questions.create( text: 'question 1', response_type: 'short_text')
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

      it 'should deny access to an attempt to create a question by an unauthorized user' do
        post :create, { question: { section_id: @section.id}}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to a billing users  attempt to create a question by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :create, { question: { section_id: @section.id}}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an attempt to edit a question by an unauthorized user' do
        post :edit, { id: @question.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users  attempt to edit a question by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :edit, { id: @question.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end


      it 'should deny access to an attempt to update a question by an unauthorized user' do
        post :update, { id: @question.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users attempt to update a question by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :update, { id: @question.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an attempt to delete a question by an unauthorized user' do
        post :destroy, { id: @question.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users attempt to delete a question by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :destroy, { id: @question.id}
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
        @survey.state= 'active'
        @survey.save
        @survey.reload.state.should == 'active'
      end
      it 'should deny access to an attempt to create a question by an authorized user' do
        post :create, { question: { section_id: @section.id, title: 'a second question'}, format: :js}
        @section.reload.questions.size.should ==1
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
      it 'should deny access to edit  a question by an authorized user' do
        get :edit, { id: @question.id, format: :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
      it 'should deny access to update a question by an authorized user' do
        put :update, { id: @question.id, question: { title: 'a second question'}, format: :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
      it 'should deny access to delete a question by an authorized user' do
        put :destroy, { id: @question.id, question: { title: 'a second question'}, format: :js}
        @survey.questions.size.should == 1
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
    end

    describe 'inactive survey' do
      it 'should allow access to an attempt to create a question by an authorized user' do
        post :create, { question: { section_id: @section.id, text: 'a second question', response_type: 'date'}, format: :js}
        response.should render_template('show')
        @section.reload.questions.size.should == 2
      end
      it 'should allow access to edit  a question by an authorized user' do
        get :edit, { id: @question.id, format: :js}
        response.should render_template('edit')
      end
      it 'should allow access to update a question by an authorized user' do
        put :update, { id: @question.id, question: { text: 'a second question'}, format: :js}
        response.should render_template('show')
        @question.reload.text.should == 'a second question'
      end
      it 'should allow access to delete a question by an authorized user' do
        put :destroy, { id: @question.id, question: { title: 'a second question'}, format: :js}
        response.should render_template('sections/show')
        @survey.questions.size.should == 0
      end
    end
    it 'should allow access to view a question by an authorized user' do
      get :show, { id: @question.id, format: :js}
      response.should render_template('show')
    end
  end
end
