require 'spec_helper'

describe Admin::SearchesController do
  before(:each) do
    @user = FactoryGirl.create(:user, netid: 'test_user')
    login_user
    controller.current_user.stub(:has_system_access?).and_return(true)
  end

  describe 'PATCH release_data' do
    before(:each) do
      @study  = FactoryGirl.create(:study)
      @search = @study.searches.create( name: 'test', user_id: controller.current_user.id )
      @participant1 = FactoryGirl.create(:participant, stage: 'approved')
      @participant2 = FactoryGirl.create(:participant, stage: 'approved')
      @participant3 = FactoryGirl.create(:participant, stage: 'approved')
      @valid_release_data_attributes = { id: @search.id, participant_ids: { @participant1.id => @participant1.id, @participant2.id => @participant2.id}, start_date: Date.today, warning_date: Date.tomorrow, end_date: Date.today + 2.days}
    end

    describe 'authorized access' do
      before(:each) do
        controller.current_user.stub(:admin?).and_return(true)
      end

      describe 'when corresponding EmailNotification is not available' do
        it 'generates warning message' do
          email_notification = EmailNotification.batch_released
          email_notification.deactivate
          email_notification.save!

          patch :release_data, @valid_release_data_attributes
          expect(flash[:notice]).to eq 'Participant Data Released.'
          expect(flash[:error]).to eq 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated or emails for assosiated users are not available)'
        end
      end

      describe 'when corresponding EmailNotification is available' do
        it 'sends welcome email and admin email when corresponding EmailNotification is available' do
          expect {
            patch :release_data, @valid_release_data_attributes
          }.to change(ActionMailer::Base.deliveries, :size).by(1)
        end

        it 'generates proper notification message' do
          patch :release_data, @valid_release_data_attributes
          expect(flash[:notice]).to eq 'Participant Data Released. Researcher had been notified of data release.'
        end
      end

      it 'redirects to the searches index page' do
        patch :release_data, @valid_release_data_attributes
        expect(response).to redirect_to admin_searches_path
      end
    end
  end
end
