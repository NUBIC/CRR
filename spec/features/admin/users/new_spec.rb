require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'creating an user', type: :feature do
    let(:path) { new_admin_user_path }

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
          expect(page).to have_content("Netid can't be blank")
        end

        it 'provides client side validation', js: true do
          visit path
          click_on('Create')
          expect(find(".controls label[for='user_netid']")).to have_content('This field is required')
        end

        it 'allows to create an user' do
          visit path
          fill_in('Netid', with: 'other_test_user')
          click_on('Create')

          expect(page).to have_current_path(admin_users_path)
          expect(page).to have_content('other_test_user')
        end
      end
    end
  end
end
