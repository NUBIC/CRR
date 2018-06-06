require 'rails_helper'
ROLES = ['data_manager?', 'researcher?', 'admin?']

RSpec.describe Admin::CommentsController, type: :controller do
  before(:each) do
    @user         = FactoryBot.create(:user, netid: 'test_user')
    @study        = FactoryBot.create(:study, state: 'active')
    @other_study  = FactoryBot.create(:study)
    @commentable  = @study.searches.create(name: Faker::Lorem.sentence)
    @comment      = @commentable.comments.create(content: Faker::Lorem.sentence)
    @params       = { content: Faker::Lorem.sentence }
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized user' do
    describe 'GET index' do
      before(:each) do
        ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
        get :index, xhr: true, params: { search_id: @commentable.id }
      end
      include_examples 'unauthorized access: admin controller'
    end

    describe 'POST create' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :create, xhr: true, params: { search_id: @commentable.id, comment: @params }
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          post :create, xhr: true, params: { search_id: @commentable.id, comment: @params }
        end
        include_examples 'unauthorized access: admin controller'
      end
    end

    describe 'POST destroy' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          delete :destroy, xhr: true, params: { search_id: @commentable.id, id: @comment.id }
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          delete :destroy, xhr: true, params: { search_id: @commentable.id, id: @comment.id }
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on same study, not owner' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @study
          delete :destroy, xhr: true, params: { search_id: @commentable.id, id: @comment.id }
        end
        include_examples 'unauthorized access: admin controller'
      end
    end
  end

  describe 'authorized access' do
    describe 'GET index' do
      ROLES.each do |role|
        describe "for role #{role}"do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
            @user.studies << @study if role != 'admin?'
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
            get :index, xhr: true, params: { search_id: @commentable.id }
          end

          it "sets commentable"  do
            expect(assigns(:commentable)).to eq @commentable
          end

          it 'sets comments' do
            expect(assigns(:comments)).to eq @commentable.comments
          end

          it 'builds a new comment' do
            expect(assigns(:comment)).to be_a Comment
            expect(assigns(:comment)).to be_new_record
            expect(assigns(:comment).commentable).to eq @commentable
          end
        end
      end
    end

    describe 'POST create' do
      ROLES.each do |role|
        describe "for role #{role}"do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
            @user.studies << @study if role != 'admin?'
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
          end

          describe 'with valid params' do
            it 'creates a new comment' do
              expect{ post :create, xhr: true, params: { search_id: @commentable.id, comment: @params} }.to change{Comment.count}.by(1)
            end

            it 'assigns a new comment' do
              post :create, xhr: true, params: { search_id: @commentable.id, comment: @params }
              expect(assigns(:comment)).to be_a(Comment)
              expect(assigns(:comment)).to be_new_record
            end

            it 'renders INDEX' do
              post :create, xhr: true,  params: { search_id: @commentable.id, comment: @params }
              expect(response).to render_template(:index)
            end
          end

          describe 'with invalid params' do
            before(:each) do
              allow_any_instance_of(Comment).to receive(:save).and_return(false)
            end

            it 'does not create a comment' do
              expect{ post :create, xhr: true, params: { search_id: @commentable.id, comment: @params } }.not_to change{Comment.count}
            end

            it 'populates "error" flash' do
              post :create, xhr: true, params: { search_id: @commentable.id, comment: @params }
              expect(flash['error']).not_to be_nil
            end

            it 'renders INDEX' do
              post :create, xhr: true, params: { search_id: @commentable.id, comment: @params }
              expect(response).to render_template(:index)
            end
          end
        end
      end
    end

    describe 'POST destroy' do
      ROLES.each do |role|
        describe "for role #{role}"do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
             if role != 'admin?'
              @user.studies << @study
              @comment.user = @user
              @comment.save
            end
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
          end

          it 'destroys a comment' do
            expect {
              delete :destroy, xhr: true, params: { search_id: @commentable.id, id: @comment.id }
            }.to change{Comment.count}.by(-1)
          end

            it 'assigns a new comment' do
              delete :destroy, xhr: true, params: { search_id: @commentable.id, id: @comment.id }
              expect(assigns(:comment)).to be_a(Comment)
              expect(assigns(:comment)).to be_new_record
            end

            it 'renders INDEX' do
              delete :destroy, xhr: true, params: { search_id: @commentable.id, id: @comment.id }
              expect(response).to render_template(:index)
            end
        end
      end
    end
  end
end