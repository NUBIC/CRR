require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'listing surveys', type: :feature do
    let(:path) { admin_surveys_path }

    describe 'unauthorized access' do
      describe 'public account access' do
        include_context 'user login'

        it 'redirects user to admin login page' do
          visit path
          expect(page).to have_current_path(new_user_session_path)
          expect(page).to have_content('You need to sign in before continuing.')
        end
      end

      describe 'researcher access' do
        include_context 'researcher login'

        it 'redirects user to dashboard page' do
          visit path
          expect(page).to have_current_path(admin_root_path)
          expect(page).to have_content('Access Denied')
        end
      end
    end

    describe 'authorized access' do
      describe 'admin access' do
        include_context 'admin login'

        before(:each) do
          (1..3).each do |i|
            FactoryGirl.create(:survey)
          end
        end

        it 'displays a list of surveys' do
          visit path
          Survey.all.each do |survey|
            expect(page).to have_link(survey.title, href: admin_survey_path(id: survey.id))
          end
        end

        it 'indicates tier 2 surveys' do
          survey = Survey.first
          survey.tier_2 = true
          survey.save!

          visit path
          within(find('tbody tr', match: :first)) do
            expect(page).to have_selector('span.user-circle')
          end
        end

        it 'displays a number of surveys' do
          visit path
          expect(page).to have_content("Surveys (#{Survey.count}")
        end

        it 'allows to add a survey' do
          visit path
          expect(page).to have_link('Add a survey', href: new_admin_survey_path)
        end

        it 'displays inactive surveys as muted' do
          survey = Survey.first
          survey.deactivate
          survey.save

          visit path
          within(find('tbody tr', match: :first)) do
            expect(page).to have_selector('td.muted')
          end
        end
      end
    end
  end
end
