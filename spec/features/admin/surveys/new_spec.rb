require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'creating a survey', type: :feature do
    let(:path) { new_admin_survey_path }

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

        it 'provides server side validation' do
          visit path
          click_on('Create')
          expect(page).to have_content("Title can't be blank")
        end

        it 'provides client side validation', js: true do
          visit path
          click_on('Create')
          expect(find(".controls label[for='survey_title']")).to have_content('This field is required')
        end

        it 'allows to create a survey' do
          visit path
          fill_in('Title', with: 'test survey #1')
          click_on('Create')

          expect(page).to have_current_path(admin_survey_path(Survey.last.id))
          expect(page).to have_content('test survey #1')
        end
      end
    end
  end
end