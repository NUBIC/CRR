require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'listing users', type: :feature do
    let(:path) { admin_users_path }

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
          @user          = User.find_by_netid('test_user')
          @inactive_user = FactoryGirl.create(:user, netid: 'other_test_user')
          @inactive_user.deactivate
          @inactive_user.save!
          (1..3).each do |i|
            @user.studies << FactoryGirl.create(:study)
          end
        end

        it 'displays a list of active users', js: true do
          visit path
          expect(page).to have_link("Active (#{User.active.count})", href: admin_users_path(state: 'active'))
          expect(page).to have_link("Inactive (#{User.inactive.count})", href: admin_users_path(state: 'inactive'))
          within '#users_index_table' do
            expect(page).to have_link(@user.full_name, href: edit_admin_user_path(id: @user.id))
            expect(page).not_to have_content(@inactive_user.full_name)
          end
        end

        it 'displays number of users' do
          visit path
          expect(page).to have_content("Users (#{User.count}")
        end

        it 'allows to add a user' do
          visit path
          expect(page).to have_link('Add an user', href: new_admin_user_path)
        end

        it 'displays list of inactive users', js: true do
          visit path
          click_on("Inactive (#{User.inactive.count})")
          expect(page).to have_link("Active (#{User.active.count})", href: admin_users_path(state: 'active'))
          expect(page).to have_link("Inactive (#{User.inactive.count})", href: admin_users_path(state: 'inactive'))

          within '#users_index_table' do
            expect(page).to have_link(@inactive_user.full_name, href: edit_admin_user_path(id: @inactive_user.id))
            expect(page).not_to have_content(@user.full_name)
          end
        end

        it 'displays a list of user studies', js: true do
          visit path
          within '#users_index_table' do
            @user.studies.each do |study|
              expect(page).to have_link(study.name, href: admin_study_path(id: study.id))
            end
          end
        end

        it 'allows to see a full list of user studies', js: true do
          (1..3).each do |i|
            @user.studies << FactoryGirl.create(:study)
          end

          visit path
          within '#users_index_table' do
            @user.studies.each_with_index do |study, i|
              if i < 3
                expect(page).to have_link(study.name, href: admin_study_path(id: study.id))
              else
                expect(page).not_to have_content(study.name)
              end
            end

            expect(page).to have_selector('li.show_button', text: 'See more...')
            find('li.show_button', text: 'See more...').click
            @user.studies.each do |study|
              expect(page).to have_link(study.name, href: admin_study_path(id: study.id))
            end
          end
        end
      end
    end
  end
end
