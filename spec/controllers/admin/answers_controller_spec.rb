require 'rails_helper'

RSpec.describe Admin::AnswersController, type: :controller do
  before(:each) do
    @survey   = FactoryGirl.create( :survey, multiple_section: true)
    @section  = @survey.sections.create(title: 'section 1')
    @question = @section.questions.create(text: 'question 1', response_type: 'pick_one')
    @answer   = @question.answers.create(text: 'answer 1')
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
    @params   = { question_id: @question.id, text: 'a second answer', response_type: 'date'}
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

      describe 'GET new' do
        before(:each) do
          get :new, question_id: @question.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST create' do
        before(:each) do
          post :create, answer: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'GET show' do
        before(:each) do
          get :show, id: @answer.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'GET edit' do
        before(:each) do
          get :edit, id: @answer.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST update' do
        before(:each) do
          post :update, id: @answer.id, answer: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST destroy' do
        before(:each) do
          post :destroy, id: @answer.id
        end
        include_examples 'unauthorized access: admin controller'
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

      describe 'GET new' do
        before(:each) do
          get :new, question_id: @question.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST create' do
        before(:each) do
          post :create, answer: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'GET edit' do
        before(:each) do
          get :edit, id: @answer.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST update' do
        before(:each) do
          post :update, id: @answer.id, answer: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'POST destroy' do
        before(:each) do
          post :destroy, id: @answer.id
        end
        include_examples 'unauthorized access: admin controller'
      end
    end

    describe 'inactive survey' do
      describe 'GET new' do
        it 'renders NEW template in HTML format' do
          get :new, question_id: @question.id
          expect(response).to render_template('new')
        end

        it 'renders NEW template in JS format' do
          xhr :get, :new, question_id: @question.id
          expect(response).to render_template('new')
        end
      end

      describe 'POST create' do
        describe 'with valid params' do
          it 'creates an answer' do
            expect {
              post :create, answer: @params
            }.to change{Answer.count}.by(1)
          end

          it 'populates "notice" flash' do
            post :create, answer: @params
            expect(flash['notice']).to eq 'Updated'
          end

          it 'redirects to EDIT question in HTML format' do
            post :create, answer: @params
            expect(response).to redirect_to(controller: :questions, action: :edit, id: Answer.last.question.id)
          end

          it 'renders SHOW template in JS format' do
            xhr :post, :create, answer: @params
            expect(response).to render_template('show')
          end
        end

        describe 'with invalid params' do
          before(:each) do
            allow_any_instance_of(Answer).to receive(:save).and_return(false)
          end

          it 'does not create an answer' do
            expect {
              post :create, answer: @params
            }.not_to change{Answer.count}
          end

          it 'populates "error" flash' do
            post :create, answer: @params
            expect(flash['error']).not_to be_nil
          end

          it 'redirects to EDIT question in HTML format' do
            post :create, answer: @params
            expect(response).to redirect_to(controller: :questions, action: :edit, id: Answer.last.question.id)
          end

          it 'renders SHOW template in JS format' do
            xhr :post, :create, answer: @params
            expect(response).to render_template('show')
          end
        end
      end

      describe 'GET show' do
        it 'renders SHOW template in JS format' do
          xhr :get, :show, id: @answer.id
          expect(response).to render_template('show')
        end
      end

      describe 'GET edit' do
        it 'renders EDIT template in JS format' do
          xhr :get, :edit, id: @answer.id
          expect(response).to render_template('edit')
        end

        it 'renders EDIT template in HTML format' do
          get :edit, id: @answer.id
          expect(response).to render_template('edit')
        end
      end

      describe 'POST update' do
        describe 'with valid params' do
          before(:each) do
            xhr :post, :update, id: @answer.id, answer: @params
          end

          it 'updates an answer' do
            expect(@answer.reload.text).to eq 'a second answer'
          end

          it 'populates "notice" flash' do
            expect(flash['notice']).to eq 'Updated'
          end

          it 'renders SHOW template in JS format' do
            expect(response).to render_template('show')
          end
        end

        describe 'with invalid params' do
          before(:each) do
            allow_any_instance_of(Answer).to receive(:update_attributes).and_return(false)
            xhr :post, :update, id: @answer.id, answer: @params
          end

          it 'does not update an answer' do
            expect(@answer.text).not_to eq 'a second answer'
          end

          it 'renders SHOW template in JS format' do
            expect(response).to render_template('show')
          end
        end
      end

      describe 'POST destroy' do
        it 'destroys answer' do
          expect {
            xhr :post, :destroy, id: @answer.id
          }.to change{Answer.count}.by(-1)
        end

        it 'renders question show template' do
          xhr :post, :destroy, id: @answer.id
          expect(response).to render_template('admin/questions/show')
        end
      end
    end
  end
end
