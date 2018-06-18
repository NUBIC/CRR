require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'updating an user', type: :feature do
    let(:user) { User.find_by_netid('test_user') || FactoryBot.create(:user, netid: 'test_user') }
    let(:other_user) { User.find_by_netid('test_user') || FactoryBot.create(:user, netid: 'test_user') }

    let(:path) { edit_admin_user_path(user.id) }

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

        it 'displays uneditable NetID' do
          visit path
          expect(page).to have_field('Netid', disabled: true, with: user.netid)
        end

        it 'displays uneditable email' do
          visit path
          expect(page).to have_field('Email', disabled: true, with: user.email)
        end

        it 'allows to add studies', js: true do
          (1..2).each do |i|
            FactoryBot.create(:study, state: 'active')
          end
          visit path
          fill_in('token-input-user_study_tokens', with: Study.first.name)
          find('li.token-input-dropdown-item2', text: /#{Study.first.name}/).click

          expect(page).to have_selector('p', text: /#{Study.first.name}/)
          click_on('Update')

          expect(page).to have_current_path(admin_users_path)
          expect(page).to have_content(Study.first.name)
          expect(page).not_to have_content(Study.last.name)
        end

        it 'allows to remove studies', js: true do
          (1..2).each do |i|
            user.studies << FactoryBot.create(:study, state: 'active')
          end
          visit path
          expect(page).to have_selector('p', text: /#{Study.first.name}/)
          expect(page).to have_selector('p', text: /#{Study.last.name}/)

          within('li.token-input-token', match: :first) do
            find('span.token-input-delete-token').click
          end
          expect(page).not_to have_selector('p', text: /#{Study.first.name}/)
          expect(page).to have_selector('p', text: /#{Study.last.name}/)
          page.find('body').click
          click_on('Update')

          expect(page).to have_current_path(admin_users_path)
          expect(page).not_to have_content(Study.first.name)
          expect(page).to have_content(Study.last.name)
        end

        it 'allows to deactivate active user', js: true do
          other_user = FactoryBot.create(:user, netid: 'other_test_user')
          visit edit_admin_user_path(other_user.id)
          accept_confirm do
            click_on('Deactivate')
          end
          expect(page).to have_current_path(admin_users_path)
          expect(page).not_to have_content(other_user.netid)

          click_on("Inactive (#{User.inactive.count})")
          expect(page).to have_content(other_user.netid)
        end

        it 'allows to activate inactive user', js: true do
          other_user = FactoryBot.create(:user, netid: 'other_test_user')
          other_user.deactivate
          other_user.save!

          visit edit_admin_user_path(other_user.id)
          accept_confirm do
            click_on('Activate')
          end
          expect(page).to have_current_path(admin_users_path)
          expect(page).to have_content(other_user.netid)

          click_on("Inactive (#{User.inactive.count})")
          expect(page).not_to have_content(other_user.netid)
        end
      end
    end
  end
end
