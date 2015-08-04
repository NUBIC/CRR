require 'spec_helper'

describe Admin::SectionsController do
  before(:each) do
    @survey = FactoryGirl.create(:survey,:multiple_section=>true)
    @section = @survey.sections.create(:title=>'section 1')
    login_user
    controller.current_user.stub(:has_system_access?).and_return(true)
  end

  describe 'unauthorized user(data manager)' do
    ['data_manager?','researcher?'].each do |role|
      before(:each) do
        controller.current_user.stub(:admin?).and_return(false)
        all_roles = ['data_manager?','researcher?']
        all_roles.each{|r| r.eql?(role) ? controller.current_user.stub(r.to_sym).and_return(true) : controller.current_user.stub(r.to_sym).and_return(false)}
      end

      it 'should deny access to an attempt to create a section on an unauthorized user' do
        post :create, { section: { survey_id: @survey.id } }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to a billing users  attempt to create a section by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :create, { section: { survey_id: @survey.id } }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an attempt to edit a section by an unauthorized user' do
        post :edit, { id: @section.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users  attempt to edit a section by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :edit, { id: @section.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end


      it 'should deny access to an attempt to update a section by an unauthorized user' do
        post :update, { id: @section.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users attempt to update a section by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :update, { id: @section.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an attempt to delete a section by an unauthorized user' do
        post :destroy, { id: @section.id }
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to an billing users attempt to delete a section by an unauthorized user' do
        controller.current_user.stub(:billing?).and_return(true)
        post :destroy, { id: @section.id }
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
        @survey.sections.first.questions.create( text: 'question 1', response_type: 'date')
        @survey.state= 'active'
        @survey.save
        @survey.reload.state.should == 'active'
      end

      it 'should deny access to an attempt to create a section by an authorized user' do
        post :create, { section: { survey_id: @survey.id, title: 'a second section'}, format: :js}
        @survey.reload.sections.size.should ==1
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to edit a section by an authorized user' do
        get :edit, { id: @section.id, format: :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to update a section by an authorized user' do
        put :update, { id: @section.id, section: { title: 'a second section' }, format: :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end

      it 'should deny access to delete a section by an authorized user' do
        put :destroy, { id: @section.id, format: :js}
        @survey.sections.size.should == 1
        response.should redirect_to(admin_default_path)
        flash[:notice].should == 'Access Denied'
      end
    end

    describe 'inactive survey' do
      it 'should allow access to an attempt to create a section by an authorized user' do
        post :create, { section: { survey_id: @survey.id, title: 'a second section'}, format: :js}
        response.should render_template('show')
        @survey.reload.sections.size.should == 2
      end
      it 'should allow access to edit  a section by an authorized user' do
        get :edit, { id: @section.id, format: :js}
        response.should render_template('edit')
      end
      it 'should allow access to update a section by an authorized user' do
        put :update, { id: @section.id, section: { title: 'a second section' }, format: :js}
        response.should render_template('show')
        @section.reload.title.should == 'a second section'
      end
      it 'should allow access to delete a section by an authorized user' do
        put :destroy, { id: @section.id, section: { title: 'a second section' }, format: :js}
        response.should render_template('surveys/show')
        @survey.sections.size.should == 0
      end
    end
    it 'should allow access to view a section by an authorized user' do
      get :show, { id: @section.id, format: :js}
      response.should render_template('show')
    end
  end
end
