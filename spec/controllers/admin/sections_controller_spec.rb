require 'rails_helper'

RSpec.describe Admin::SectionsController, type: :controller do
  before(:each) do
    @survey = FactoryBot.create(:survey, multiple_section: true)
    @section = @survey.sections.create(title: 'section 1')
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized user(data manager)' do
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

      it 'should deny access to an attempt to create a section on an unauthorized user' do
        post :create, params: { section: { survey_id: @survey.id } }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to edit a section by an unauthorized user' do
        post :edit, params: { id: @section.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to update a section by an unauthorized user' do
        post :update, params: { id: @section.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to delete a section by an unauthorized user' do
        post :destroy, params: { id: @section.id }
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
        @survey.sections.first.questions.create( text: 'question 1', response_type: 'date')
        @survey.state = 'active'
        @survey.save
        expect(@survey.reload.state).to eq 'active'
      end

      it 'should deny access to an attempt to create a section by an authorized user' do
        post :create, xhr: true, params: { section: { survey_id: @survey.id, title: 'a second section'}}
        expect(@survey.reload.sections.size).to eq 1
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to edit a section by an authorized user' do
        get :edit, xhr: true, params: { id: @section.id}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to update a section by an authorized user' do
        put :update, xhr: true, params: { id: @section.id, section: { title: 'a second section' }}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end

      it 'should deny access to delete a section by an authorized user' do
        put :destroy, xhr: true, params: { id: @section.id}
        expect(@survey.sections.size).to eq 1
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['error']).to eq 'Access Denied'
      end
    end

    describe 'inactive survey' do
      it 'should allow access to an attempt to create a section by an authorized user' do
        post :create, xhr: true, params: { section: { survey_id: @survey.id, title: 'a second section'}}
        expect(response).to render_template('show')
        expect(@survey.reload.sections.size).to eq 2
      end

      it 'should allow access to edit  a section by an authorized user' do
        get :edit, xhr: true, params: { id: @section.id }
        expect(response).to render_template('edit')
      end

      it 'should allow access to update a section by an authorized user' do
        put :update, xhr: true, params: { id: @section.id, section: { title: 'a second section' }}
        expect(response).to render_template('show')
        expect(@section.reload.title).to eq 'a second section'
      end

      it 'should allow access to delete a section by an authorized user' do
        expect {
          put :destroy, xhr: true, params: { id: @section.id }
        }.to change{ Section.count }.by(-1)
        expect(response).to render_template('surveys/show')
      end
    end

    it 'should allow access to view a section by an authorized user' do
      get :show, xhr: true, params: { id: @section.id }
      expect(response).to render_template('show')
    end
  end
end
