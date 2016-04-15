require 'spec_helper'

describe Admin::AnswersController do
  before(:each) do
    @survey = FactoryGirl.create( :survey, multiple_section: true)
    @section = @survey.sections.create(title: 'section 1')
    @question = @section.questions.create(text: 'question 1', response_type: 'pick_one')
    @answer = @question.answers.create(text: 'answer 1')
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized user' do
    ['data_manager?', 'researcher?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:admin?).and_return(false)
        all_roles = ['data_manager?','researcher?']
        all_roles.each do |r|
          if r.eql?(role)
            allow(controller.current_user).to receive(r.to_sym).and_return(true)
          else
            allow(controller.current_user).to receive(r.to_sym).and_return(false)
          end
        end
      end

      it 'should deny access to an attempt to create a answer by an unauthorized user' do
        post :create, { answer: { question_id: @question.id}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to a billing users  attempt to create a answer by an unauthorized user' do
        allow(controller.current_user).to receive(:billing?).and_return(true)
        post :create, { answer: { question_id: @question.id}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to edit a answer by an unauthorized user' do
        post :edit, { id: @answer.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an billing users  attempt to edit a answer by an unauthorized user' do
        allow(controller.current_user).to receive(:billing?).and_return(true)
        post :edit, { id: @answer.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end


      it 'should deny access to an attempt to update a answer by an unauthorized user' do
        post :update, { id: @answer.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an billing users attempt to update a answer by an unauthorized user' do
        allow(controller.current_user).to receive(:billing?).and_return(true)
        post :update, { id: @answer.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to delete a answer by an unauthorized user' do
        post :destroy, { id: @answer.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an billing users attempt to delete a answer by an unauthorized user' do
        allow(controller.current_user).to receive(:billing?).and_return(true)
        post :destroy, { id: @answer.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end
    end
  end

  describe 'authorized user' do
    before(:each) do
      allow(controller.current_user).to receive(:admin?).and_return(true)
    end

    describe 'active survey' do
      before(:each) do
        @answer2 = @question.answers.create( text: 'answer 2')
        @survey.state = 'active'
        @survey.save
        expect(@survey.reload.state).to eq 'active'
      end

      it 'should deny access to an attempt to create a answer by an authorized user' do
        xhr :post, :create, { answer: { question_id: @question.id, title: 'a second answer'}}
        expect(@question.reload.answers.size).to eq 2
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to edit  a answer by an authorized user' do
        xhr :get, :edit, { id: @answer.id, format:  :js}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to update a answer by an authorized user' do
        xhr :put, :update, { id: @answer.id, answer: { title: 'a second answer'}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to delete a answer by an authorized user' do
        xhr :put, :destroy, { id: @answer.id, answer: { title: 'a second answer'}}
        expect(@question.answers.size).to eq 2
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end
    end

    describe 'inactive survey' do
      it 'should allow access to an attempt to create a answer by an authorized user' do
        xhr :post, :create, { answer: { question_id: @question.id, text: 'a second answer', response_type: 'date'}}
        expect(response).to render_template('show')
        expect(@question.reload.answers.size).to eq 2
      end
      it 'should allow access to edit  a answer by an authorized user' do
        xhr :get, :edit, { id: @answer.id }
        expect(response).to render_template('edit')
      end
      it 'should allow access to update a answer by an authorized user' do
        xhr :put, :update, { id: @answer.id, answer: { text: 'a second answer'}}
        expect(response).to render_template('show')
        expect(@answer.reload.text).to eq 'a second answer'
      end
      it 'should allow access to delete a answer by an authorized user' do
        xhr :put, :destroy, { id: @answer.id, answer: { title: 'a second answer'}}
        expect(response).to render_template('questions/show')
        expect(@question.reload.answers.size).to eq 0
      end
    end
    it 'should allow access to view a answer by an authorized user' do
      xhr :get, :show, { id: @answer.id }
      expect(response).to render_template('show')
    end
  end
end
