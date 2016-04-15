require 'spec_helper'

describe Admin::RelationshipsController do
  before(:each) do
    @participant1 = FactoryGirl.create(:participant)
    @participant2 = FactoryGirl.create(:participant)
    @category = Relationship::CATEGORIES.sample
    @relationship = Relationship.create(origin_id: @participant1.id, destination_id: @participant2.id, category: @category)
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized access' do
    ['researcher?'].each do |role|
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

      it "should deny access to an attempt by a #{role} to create a relationship" do
        post :create, { relationship: { origin_id: @participant1.id, destination_id: @participant2.id, category: @category}}
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to edit a relationship by a #{role}' do
        post :edit, { id: @relationship.id, participant_id: @participant1.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to update a relationship by a #{role}' do
        post :update, { id: @relationship.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end

      it 'should deny access to an attempt to delete a relationship by a #{role}' do
        post :destroy, { id: @relationship.id }
        expect(response).to redirect_to(controller: :users, action: :dashboard)
        expect(flash['notice']).to eq 'Access Denied'
      end
    end
  end

  describe 'authorized user' do
    ['data_manager?', 'admin?'].each do |role|
      before(:each) do
        allow(controller.current_user).to receive(:researcher?).and_return(true)
        all_roles = ['data_manager?', 'admin?']
        all_roles.each do |r|
          if r.eql?(role)
            allow(controller.current_user).to receive(r.to_sym).and_return(true)
          else
            allow(controller.current_user).to receive(r.to_sym).and_return(false)
          end
        end
      end

      it 'should allow access to an attempt to create a relationship by an #{role}' do
        participant3 = FactoryGirl.create(:participant)
        post :create, { relationship: { category: @category, origin_id: participant3.id, destination_id: @participant2.id} }
        expect(response).to redirect_to(controller: :participants, action: :show, id: participant3.id)
      end

      it 'should create a relationship' do
        participant3 = FactoryGirl.create(:participant)
        expect {
          post :create, { relationship: { category: @category, origin_id: participant3.id, destination_id: @participant2.id} }
        }.to change{Relationship.count}.by(1)
      end

      it 'should allow access to edit  a relationship by an #{role}' do
        get :edit, { id: @relationship.id, participant_id: @participant1.id }
        expect(response).to render_template('edit')
      end

      it 'should allow access to update a relationship by an #{role}' do
        category = Relationship::CATEGORIES.sample
        put :update, { id: @relationship.id, relationship: { category: category } }
        expect(response).to redirect_to(controller: :participants, action: :show, id: @participant1.id)
        expect(@relationship.reload.category).to eq category
      end

      it 'should allow access to delete a relationship by an #{role}' do
        expect {
          put :destroy, { id: @relationship.id }
        }.to change{ Relationship.count }.by(-1)
        expect(response).to redirect_to(controller: :participants, action: :show, id: @participant1.id)
      end
    end
  end
end
