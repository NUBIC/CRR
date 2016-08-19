require 'rails_helper'

RSpec.describe Admin::QuestionsController, type: :controller do
  before(:each) do
    @survey = FactoryGirl.create( :survey, multiple_section: true)
    @section = @survey.sections.create( title: 'section 1')
    @question = @section.questions.create( text: 'question 1', response_type: 'short_text')
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized user' do
    ['data_manager?', 'researcher?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:admin?).and_return(false)
        all_roles = ['data_manager?', 'researcher?']
        all_roles.each do |r|
          if r.eql?(role)
            allow(controller.current_user).to receive(r.to_sym).and_return(true)
          else
            allow(controller.current_user).to receive(r.to_sym).and_return(false)
          end
        end
      end

      it 'should deny access to an attempt to create a question by an unauthorized user' do
        post :create, { question: { section_id: @section.id}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to edit a question by an unauthorized user' do
        post :edit, { id: @question.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to update a question by an unauthorized user' do
        post :update, { id: @question.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to delete a question by an unauthorized user' do
        post :destroy, { id: @question.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
    end
  end

  describe 'authorized user' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
    end

    describe 'active survey' do
      before(:each) do
        @survey.state = 'active'
        @survey.save
        expect(@survey.reload.state).to eq 'active'
      end

      it 'should deny access to an attempt to create a question by an authorized user' do
        xhr :post, :create, { question: { section_id: @section.id, title: 'a second question'}}
        expect(@section.reload.questions.size).to eq 1
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to edit  a question by an authorized user' do
        get :edit, { id: @question.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to update a question by an authorized user' do
        xhr :put, :update, { id: @question.id, question: { title: 'a second question'}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to delete a question by an authorized user' do
        xhr :put, :destroy, { id: @question.id, question: { title: 'a second question'}}
        expect(@survey.questions.size).to eq 1
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'inactive survey' do
      it 'should allow access to an attempt to create a question by an authorized user' do
        xhr :post, :create, { question: { section_id: @section.id, text: 'a second question', response_type: 'date'}}
        expect(response).to render_template('show')
        expect(@section.reload.questions.size).to eq 2
      end

      it 'should allow access to edit  a question by an authorized user' do
        get :edit, { id: @question.id}
        expect(response).to render_template('edit')
      end

      it 'should allow access to update a question by an authorized user' do
        xhr :put, :update, { id: @question.id, question: { text: 'a second question'}}
        expect(response).to render_template('show')
        expect(@question.reload.text).to eq 'a second question'
      end

      it 'should allow access to delete a question by an authorized user' do
        xhr :put, :destroy, { id: @question.id, question: { title: 'a second question'}}
        expect(response).to render_template('sections/show')
        expect(@survey.questions.size).to eq 0
      end
    end

    it 'should allow access to view a question by an authorized user' do
      get :show, { id: @question.id}
      expect(response).to render_template('show')
    end
  end
end
