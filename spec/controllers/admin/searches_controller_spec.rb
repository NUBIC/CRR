require 'rails_helper'

RSpec.describe Admin::SearchesController, type: :controller do
  ROLES   = ['data_manager?', 'researcher?', 'admin?']
  STATES  = Search.aasm.states.map(&:name)

  before(:each) do
    @user               = FactoryGirl.create(:user, netid: 'test_user')
    @study              = FactoryGirl.create(:study, state: 'active')
    @other_study        = FactoryGirl.create(:study)
    @params             = { "study_id" => @study.id.to_s, "name" => Faker::Lorem.sentence}
    @search             = @study.searches.create(name: Faker::Lorem.sentence)
    @other_search       = @study.searches.create(name: Faker::Lorem.sentence)
    @other_study_search = @other_study.searches.create(name: Faker::Lorem.sentence)
    @participant        = FactoryGirl.create(:participant, first_name: 'Joe', last_name: 'Doe', stage: 'approved', address_line1: '123 Main St', address_line2: 'Apt #123', city: 'Chicago', state: 'IL', zip: '12345', email: 'test@test.com', primary_phone: '123-456-7890', secondary_phone: '123-345-6789')
    @study_involvement  = FactoryGirl.create(:study_involvement, study: @study, participant: @participant)
    @search.search_participants.create!(participant: @participant, released: true)
    login_user
    allow(controller.current_user).to receive(:has_system_access?).and_return(true)
  end

  describe 'unauthorized user' do
    describe 'GET index' do
      before(:each) do
        ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
        get :index
      end
      include_examples 'unauthorized access: admin controller'
    end

    describe 'GET new' do
      before(:each) do
        ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
        get :new
      end
      include_examples 'unauthorized access: admin controller'
    end

    describe 'POST create' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :create, search: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'copying unauthorized search' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :create, search: @params, source_search: @search
        end
        include_examples 'unauthorized access: admin controller'
      end
    end

    describe 'GET show' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          get :show, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          get :show, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end
    end

    describe 'GET edit' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          get :edit, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          get :edit, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on study for searches in other than "new" state' do
        STATES.each do |state|
          unless state == :new
            before(:each) do
              allow(controller.current_user).to receive(:researcher?).and_return(true)
              @user.studies << @study
              @search.state = state
              @search.save!
              get :edit, id: @search.id
            end
            include_examples 'unauthorized access: admin controller'
          end
        end
      end

      describe 'searches in other than "new" and "data_requested" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless [:new, :data_requested].include? state
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                get :edit, id: @search.id
              end
              include_examples 'unauthorized access: admin controller'
            end
          end
        end
      end
    end

    describe 'POST update' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :update, id: @search.id, search: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          post :update, id: @search.id, search: @params
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on study for searches in other than "new" state' do
        STATES.each do |state|
          unless state == :new
            before(:each) do
              allow(controller.current_user).to receive(:researcher?).and_return(true)
              @user.studies << @study
              @search.state = state
              @search.save!
              post :update, id: @search.id, search: @params
            end
            include_examples 'unauthorized access: admin controller'
          end
        end
      end

      describe 'searches in other than "new" and "data_requested" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless [:new, :data_requested].include? state
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                post :update, id: @search.id, search: @params
              end
            end
          end
        end
      end
    end

    describe 'POST destroy' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :destroy, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          post :destroy, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on study for searches in other than "new" state' do
        STATES.each do |state|
          unless state == :new
            before(:each) do
              allow(controller.current_user).to receive(:researcher?).and_return(true)
              @user.studies << @study
              @search.state = state
              @search.save!
              post :destroy, id: @search.id
            end
            include_examples 'unauthorized access: admin controller'
          end
        end
      end

      describe 'searches in other than "new" and "data_requested" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless [:new, :data_requested].include? state
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                post :destroy, id: @search.id
              end
              include_examples 'unauthorized access: admin controller'
            end
          end
        end
      end
    end

    describe 'POST request_data' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :request_data, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          post :request_data, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'searches in other than "new" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless [:new].include? state
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                post :request_data, id: @search.id
              end
              include_examples 'unauthorized access: admin controller'
            end
          end
        end
      end
    end

    describe 'POST release_data' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :release_data, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'searches in other than "new" and "data_requested" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless [:new, :data_requested].include? state
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                post :release_data, id: @search.id
              end
              include_examples 'unauthorized access: admin controller'
            end
          end
        end
      end
    end

    describe 'POST return_data' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :return_data, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          post :return_data, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'searches in other than "data_released" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless state == :data_released
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                post :return_data, id: @search.id
              end
              include_examples 'unauthorized access: admin controller'
            end
          end
        end
      end
    end

    describe 'POST approve_return' do
      describe 'without a role' do
        before(:each) do
          ROLES.map{|role| allow(controller.current_user).to receive(role.to_sym).and_return(false) }
          post :approve_return, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on another study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @other_study
          post :approve_return, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'researcher on same study' do
        before(:each) do
          allow(controller.current_user).to receive(:researcher?).and_return(true)
          @user.studies << @study
          post :approve_return, id: @search.id
        end
        include_examples 'unauthorized access: admin controller'
      end

      describe 'searches in other than "data_returned" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless state == :data_returned
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                post :return_data, id: @search.id
              end
              include_examples 'unauthorized access: admin controller'
            end
          end
        end
      end

      describe 'searches in other than "data_released" state' do
        ROLES.each do |role|
          STATES.each do |state|
            unless state == :data_released
              before(:each) do
                allow(controller.current_user).to receive(role.to_sym).and_return(true)
                @user.studies << @study if role == 'researcher?'
                @search.state = state
                @search.save!
                post :return_data, id: @search.id
              end
              include_examples 'unauthorized access: admin controller'
            end
          end
        end
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
          end

          it "scopes searches to #{role}"  do
            get :index
            if role == 'admin?'
              expect(assigns(:searches)).to match_array Search.all
            else
              expect(assigns(:searches)).to match_array Search.with_user(controller.current_user)
            end
          end

          ['data_requested', 'data_released'].each do |state|
            it "filters searches by '#{state}' state" do
              @search.state = state
              @search.save!
              @other_study_search.state = state
              @other_study_search.save!

              get :index, state: state
              if role == 'admin?'
                expect(assigns(:searches)).to match_array [@search, @other_study_search]
              else
                expect(assigns(:searches)).to match_array [@search]
              end
            end
          end

          it 'filters searches by "data_expiring" state' do
            @search.warning_date = 1.day.ago
            @search.save!
            @other_study_search.warning_date = 1.day.ago
            @other_study_search.save!

            get :index, state: 'data_expiring'
            if role == 'admin?'
              expect(assigns(:searches)).to match_array [@search, @other_study_search]
            else
              expect(assigns(:searches)).to match_array [@search]
            end
          end
        end
      end
    end

    describe 'GET new' do
      ROLES.each do |role|
        describe "for role #{role}"do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
            get :new
          end

          it 'renders "new" template' do
            expect(response).to render_template(:new)
          end

          it 'sets "search" to a new instance' do
            expect(assigns(:search)).to be_a(Search)
            expect(assigns(:search)).to be_new_record
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
            it 'creates a new search' do
              expect{ post :create, search: @params }.to change{Search.count}.by(1)
            end

            it 'assigns a new search' do
              post :create, search: @params
              expect(assigns(:search)).to be_a(Search)
              expect(assigns(:search)).not_to be_new_record
            end

            it 'redirects to the search' do
              post :create, search: @params
              expect(response).to redirect_to(controller: :searches, action: :show, id: assigns(:search).id)
            end

            it 'copies existing search' do
              expect_any_instance_of(Search).to receive(:copy).with(@search)

              post :create, search: @params, source_search: @search
              expect(assigns(:search)).not_to be_new_record
              expect(assigns(:search).study_id).to eq @search.study_id
              expect(response).to redirect_to(controller: :searches, action: :show, id: assigns(:search).id)
            end
          end

          describe 'with invalid params' do
            before(:each) do
              allow_any_instance_of(Search).to receive(:save).and_return(false)
            end

            it 'does not create a search' do
              expect {
                post :create, search: @params
              }.not_to change{Search.count}
            end

            it 'populates "error" flash' do
              post :create, search: @params
              expect(flash['error']).not_to be_nil
            end

            it 'redirects to NEW search' do
              post :create, search: @params
              expect(response).to redirect_to(controller: :searches, action: :new)
            end
          end
        end
      end
    end

    describe 'GET show' do
      ROLES.each do |role|
        describe "for role #{role}" do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
            @user.studies << @study if role != 'admin?'
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
          end

          it 'renders SHOW template' do
            get :show, id: @search.id
            expect(response).to render_template('show')
          end

          it "populates released counts if data is available" do
            allow_any_instance_of(Search).to receive(:results_available?).and_return(true)
            get :show, id: @search.id
            expect(assigns(:search_participants_released)).not_to be_nil
            expect(assigns(:search_participants_returned)).not_to be_nil
            expect(assigns(:search_participants_not_returned)).not_to be_nil
          end

          it "does not populate released counts if data is not available" do
            allow_any_instance_of(Search).to receive(:results_available?).and_return(false)
            expect(assigns(:search_participants_released)).to be_nil
            expect(assigns(:search_participants_returned)).to be_nil
            expect(assigns(:search_participants_not_returned)).to be_nil
          end

          STATES.each do |state|
            if [:data_released, :data_returned, :data_return_approved].include? state
              it "retrieves participants for search in #{state} state" do
                @search.state = state
                @search.save!
                if state == 'new'
                  expect_any_instance_of(Search).to receive(:result).at_most(:twice).and_return([@participant])
                else
                  expect_any_instance_of(Search).to receive(:search_participants).at_most(:twice).and_return(SearchParticipant.where(search_id: @search.id))
                end
                get :show, id: @search.id
              end

              it "displays participants for search in #{state} state" do
                @search.state = state
                @search.save!
                get :show, id: @search.id
                expect(assigns(:participants)).not_to be_nil
              end
            else
              if role == 'researcher?'
                it "does not display participants for search in #{state} state" do
                  @search.state = state
                  @search.save!
                  get :show, id: @search.id
                  expect(assigns(:participants)).to be_nil
                end
              else
                it "displays participants for search in #{state} state" do
                  @search.state = state
                  @search.save!
                  get :show, id: @search.id
                  expect(assigns(:participants)).not_to be_nil
                end
              end
            end
          end

          it 'sets comments' do
            @search.comments.create(content: Faker::Lorem.sentence)
            get :show, id: @search.id
            expect(assigns(:comments).select(&:persisted?)).to match_array @search.comments.all
          end

          it 'builds a new comment' do
            get :show, id: @search.id
            expect(assigns(:comment)).to be_a Comment
            expect(assigns(:comment)).to be_new_record
            expect(assigns(:comment).commentable).to eq @search
          end
        end
      end
    end

    describe 'GET edit' do
      ROLES.each do |role|
        describe "for role #{role}"do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
            @user.studies << @study if role != 'admin?'
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
          end

          STATES.each do |state|
            if role == 'researcher?' && state == :new || ['admin?', 'data_manager?'].include?(role) && [:new, :data_requested].include?(state)
              it "renders EDIT template in HTML format for #{role} in #{state}" do
                get :edit, id: @search.id
                expect(response).to render_template('edit')
              end
            end
          end
        end
      end
    end

    describe 'POST update' do
      ROLES.each do |role|
        describe "for role #{role}"do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
             @user.studies << @study if role != 'admin?'
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
          end

          STATES.each do |state|
            if role == 'researcher?' && state == :new || ['admin?', 'data_manager?'].include?(role) && [:new, :data_requested].include?(state)
              describe 'with valid params' do
                it 'updates search' do
                  expect_any_instance_of(Search).to receive(:update_attributes).with(@params)
                  post :update, id: @search.id, search: @params
                end

                it 'populates "notice" flash' do
                  post :create, search: @params
                  expect(flash['notice']).not_to be_nil
                end

                it 'redirects to the search' do
                  post :update, id: @search.id, search: @params
                  expect(response).to redirect_to(controller: :searches, action: :show, id: assigns(:search).id)
                end
              end

              describe 'with invalid params' do
                before(:each) do
                  allow_any_instance_of(Search).to receive(:save).and_return(false)
                end

                it 'populates "error" flash' do
                  post :update, id: @search.id, search: @params
                  expect(flash['error']).not_to be_nil
                end

                it 'redirects to EDIT search' do
                  post :update, id: @search.id, search: @params
                  expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
                end
              end
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
             @user.studies << @study if role != 'admin?'
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
          end

          it 'destroys a search' do
            expect {
              post :destroy, id: @search.id
            }.to change{Search.count}.by(-1)
          end

          it 'redirects to searches index' do
            post :destroy, id: @search.id
            expect(response).to redirect_to(controller: :searches, action: :index)
          end
        end
      end
    end

    describe 'POST request_data' do
      ROLES.each do |role|
        describe "for role #{role}" do
          before(:each) do
            allow(controller.current_user).to receive(role.to_sym).and_return(true)
            @user.studies << @study if role != 'admin?'
            ROLES.each do |other_role|
              allow(controller.current_user).to receive(other_role.to_sym).and_return(false) unless role == other_role
            end
          end

          describe 'with valid parameters' do
            before(:each) do
              allow_any_instance_of(Search).to receive(:save).and_return(true)
            end

            it 'requests data' do
              expect_any_instance_of(Search).to receive(:request_data)
              post :request_data, id: @search.id
            end

            it 'populates "notice" flash' do
              post :request_data, id: @search.id
              expect(flash['notice']).not_to be_nil
            end

            it 'redirects to NEW search' do
              post :request_data, id: @search.id
              expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
            end
          end

          describe 'with invalid parameters' do
            before(:each) do
              allow_any_instance_of(Search).to receive(:save).and_return(false)
            end

            it 'requests data' do
              expect_any_instance_of(Search).to receive(:request_data)
              post :request_data, id: @search.id
            end

            it 'populates "notice" flash' do
              post :request_data, id: @search.id
              expect(flash['error']).not_to be_nil
            end

            it 'redirects to NEW search' do
              post :request_data, id: @search.id
              expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
            end
          end
        end
      end
    end

    describe 'POST release_data' do
      before(:each) do
        allow(controller.current_user).to receive(:admin?).and_return(true)
        allow(@search).to receive(:search_participants).and_return(Participant.where(id: @participant.id))
      end

      ['new', 'data_requested'].each do |state|
        before(:each) do
          @search.state = state
          @search.user  = @user
          @search.save!
          @valid_release_data_attributes = { id: @search.id, participant_ids: [@participant.id], start_date: Date.today, end_date: Date.today + 3.days, warning_date: Date.tomorrow}
        end

        describe 'with valid parameters' do
          before(:each) do
            allow_any_instance_of(Search).to receive(:save).and_return(true)
          end

          it 'releases data' do
            expect_any_instance_of(Search).to receive(:release_data)
            post :release_data, @valid_release_data_attributes
          end

          it 'populates "notice" flash' do
            post :release_data, @valid_release_data_attributes
            expect(flash['notice']).not_to be_nil
          end

          it 'redirects to search SHOW' do
            post :release_data, @valid_release_data_attributes
            expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
          end

          describe 'when corresponding EmailNotification is not available' do
            it 'generates warning message if email does not exist' do
              post :release_data, @valid_release_data_attributes
              expect(flash['notice']).to eq 'Participant Data Released.'
              expect(flash['error']).to eq 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated or emails for assosiated users are not available)'
            end

            it 'generates warning message if email is deactivated' do
              Setup.email_notifications
              email_notification = EmailNotification.batch_released
              email_notification.deactivate
              email_notification.save!

              post :release_data, @valid_release_data_attributes
              expect(flash['notice']).to eq 'Participant Data Released.'
              expect(flash['error']).to eq 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated or emails for assosiated users are not available)'
            end
          end

          describe 'when corresponding EmailNotification is available' do
            before :each do
              Setup.email_notifications
            end

            it 'sends welcome email and admin email when corresponding EmailNotification is available' do
              expect {
                post :release_data, @valid_release_data_attributes
              }.to change(ActionMailer::Base.deliveries, :size).by(1)
            end

            it 'generates proper notification message' do
              post :release_data, @valid_release_data_attributes
              expect(flash['notice']).to eq 'Participant Data Released. Researcher had been notified of data release.'
            end
          end
        end

        describe 'with invalid parameters' do
          before(:each) do
            allow_any_instance_of(Search).to receive(:save).and_return(false)
          end

          it 'populates "error" flash' do
            post :release_data, @valid_release_data_attributes
            expect(flash['error']).not_to be_nil
          end

          it 'redirects to search SHOW' do
            post :release_data, @valid_release_data_attributes
            expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
          end
        end
      end
    end

    describe 'POST return_data' do
      before(:each) do
        allow(controller.current_user).to receive(:admin?).and_return(true)
        @search.state = 'data_released'
        @search.save!
        @valid_return_data_attributes = { id: @search.id, study_involvement_ids: [@study_involvement.id], study_involvement_status: StudyInvolvementStatus.valid_statuses.sample[:name]}
      end

      it 'redirects to provided state' do
        params = @valid_return_data_attributes.merge({ state: 'released' })
        post :return_data, params
        expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id, state: 'released')
      end

      describe 'with valid parameters' do
        before(:each) do
          allow_any_instance_of(Search).to receive(:save).and_return(true)
        end

        it 'returns data' do
          expect_any_instance_of(Search).to receive(:process_return)
          post :return_data, @valid_return_data_attributes
        end

        it 'populates "notice" flash' do
          post :return_data, @valid_return_data_attributes
          expect(flash['notice']).not_to be_nil
        end

        it 'redirects to search SHOW' do
          post :return_data, @valid_return_data_attributes
          expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
        end
      end

      describe 'with invalid parameters' do
        before(:each) do
          allow_any_instance_of(Search).to receive(:save).and_return(false)
        end

        it 'populates "error" flash' do
          post :return_data, @valid_return_data_attributes
          expect(flash['error']).not_to be_nil
        end

        it 'redirects to search SHOW' do
          post :return_data, @valid_return_data_attributes
          expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id)
        end
      end
    end

    describe 'POST approve_return' do
      before(:each) do
        @search.state = 'data_returned'
        @search.save!

        allow_any_instance_of(Search).to receive(:data_returned?).and_return(true)
        allow(controller.current_user).to receive(:admin?).and_return(true)
      end

      describe 'with valid parameters' do
        before(:each) do
          allow_any_instance_of(Search).to receive(:save).and_return(true)
        end

        it 'returns data' do
          expect_any_instance_of(Search).to receive(:process_return_approval)
          post :approve_return, id: @search.id
        end

        it 'populates "notice" flash' do
          post :approve_return, id: @search.id
          expect(flash['notice']).not_to be_nil
        end

        it 'renders SHOW' do
          post :approve_return, id: @search.id
          expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id, state: 'returned')
        end

        describe 'processing release extension' do
          it 'creates a new search' do
            post :approve_return, id: @search.id, search: {
              name: 'Extended search',
              start_date: Date.today,
              warning_date: Date.today + 1,
              end_date: Date.today + 2
            },
            participant_ids: [@participant.id]
            expect(assigns(:new_search)).not_to be_nil
            expect(assigns(:new_search).user_id).to eq @user.id
            expect(assigns(:new_search).study).to eq @search.study
            expect(assigns(:new_search).state).to eq 'data_released'
          end

          context 'when corresponding EmailNotification is not available' do
            it 'generates warning message when corresponding EmailNotification does not exist' do
              post :approve_return, id: @search.id, search: {
                name: 'Extended search',
                start_date: Date.today,
                warning_date: Date.today + 1,
                end_date: Date.today + 2
              },
              participant_ids: [@participant.id]

              expect(flash['notice']).to match 'Data Request Extended:'
              expect(flash['error']).to eq 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated or emails for assosiated users are not available)'
            end

            it 'generates warning message when corresponding EmailNotification is not available' do
              Setup.email_notifications

              email_notification = EmailNotification.batch_released
              email_notification.deactivate
              email_notification.save!

              post :approve_return, id: @search.id, search: {
                name: 'Extended search',
                start_date: Date.today,
                warning_date: Date.today + 1,
                end_date: Date.today + 2
              },
              participant_ids: [@participant.id]

              expect(flash['notice']).to match 'Data Request Extended:'
              expect(flash['error']).to eq 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated or emails for assosiated users are not available)'
            end
          end

          context 'when corresponding EmailNotification is available' do
            before :each do
              Setup.email_notifications
            end

            it 'sends welcome email and admin email when corresponding EmailNotification is available' do
              expect {
                post :approve_return, id: @search.id, search: {
                  name: 'Extended search',
                  start_date: Date.today,
                  warning_date: Date.today + 1,
                  end_date: Date.today + 2
                },
                participant_ids: [@participant.id]
              }.to change(ActionMailer::Base.deliveries, :size).by(1)
            end

            it 'generates proper notification message' do
              post :approve_return, id: @search.id, search: {
                name: 'Extended search',
                start_date: Date.today,
                warning_date: Date.today + 1,
                end_date: Date.today + 2
              },
              participant_ids: [@participant.id]

              expect(flash['notice']).to match 'Researcher had been notified of data release.'
            end
          end
        end
      end

      describe 'with invalid parameters' do
        before(:each) do
          allow_any_instance_of(Search).to receive(:save).and_return(false)
        end

        it 'populates "error" flash' do
          post :approve_return, id: @search.id
          expect(flash['error']).not_to be_nil
        end

        it 'redirects to SHOW' do
          post :approve_return, id: @search.id
          expect(response).to redirect_to(controller: :searches, action: :show, id: @search.id, state: 'returned')
        end
      end
    end
  end
end
