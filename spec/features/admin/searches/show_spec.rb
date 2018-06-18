require 'rails_helper'
require 'support/helpers'
require 'support/shared_context'
require 'support/shared_examples'

RSpec.configure do |c|
  c.include Helpers
end

module Admin
  RSpec.describe 'displaying', type: :feature do
    let(:search)  { FactoryBot.create(:search, study: FactoryBot.create(:study, state: 'active')) }
    let(:path)    { admin_search_path(search) }

    describe 'an unreleased request' do
      describe 'with unauthorized access' do
        describe 'as public account' do
          include_context 'user login'

          it 'redirects user to admin login page from all requests page' do
            visit path
            expect(page).to have_current_path(new_user_session_path)
            expect(page).to have_content('You need to sign in before continuing.')
          end
        end

        describe 'as researcher' do
          include_context 'researcher login'

          it 'does not allow to access searches from studies not linked with the user' do
            visit path
            expect(page).to have_current_path(admin_root_path)
            expect(page).to have_content('Access Denied')
          end
        end
      end

      describe 'with authorized access' do
        describe 'as admin' do
          include_context 'admin login'
          include_examples 'shared examples for unreleased requests'
          include_examples 'shared examples for displaying requests'
        end

        describe 'as researcher' do
          include_context 'researcher login'

          before(:each) do
            @user.studies << search.study
            @user.save!
          end

          describe 'results display' do
            before :each do
              set_results
            end

            it 'does not display participants' do
              visit path
              expect(page).not_to have_content(@participant1.first_name)
              expect(page).not_to have_content(@participant1.last_name)

              expect(page).not_to have_content(@participant2.first_name)
              expect(page).not_to have_content(@participant2.last_name)
            end

            it 'displays participant counts' do
              visit path
              expect(page).to have_content('Results: 41 participants returned')
            end

            it 'allows ro request results to be released' do
              visit path
              expect(page).to have_button('Request results')
              click_on('Request results')
              expect(page).to have_current_path(path)
              expect(search.reload.state).to eq 'data_requested'
              expect(page).to have_content('Data Request Submitted')
              expect(page).to have_content('Data for this search has been requested and is pending release.')
              expect(page).to have_content('Results: 41 participants returned')
              expect(page).not_to have_content(@participant1.first_name)
              expect(page).not_to have_content(@participant1.last_name)

              expect(page).not_to have_content(@participant2.first_name)
              expect(page).not_to have_content(@participant2.last_name)
            end
          end
        end
      end
    end

    describe 'a submitted request' do
      before :each do
        set_results
        search.request_data
        search.save!
      end

      describe 'with unauthorized access' do
        describe 'with public account access' do
          include_context 'user login'

          it 'redirects user to admin login page from all requests page' do
            visit path
            expect(page).to have_current_path(new_user_session_path)
            expect(page).to have_content('You need to sign in before continuing.')
          end
        end

        describe 'with researcher access' do
          include_context 'researcher login'

          it 'does not allow to access searches from studies not linked with the user' do
            visit path
            expect(page).to have_current_path(admin_root_path)
            expect(page).to have_content('Access Denied')
          end
        end
      end

      describe 'with authorized access', js: true do
        describe 'with admin access' do
          include_context 'admin login'
          # include_examples 'shared examples for unreleased requests'
          include_examples 'shared examples for displaying requests'
        end

        describe 'with researcher access' do
          include_context 'researcher login'

          before(:each) do
            @user.studies << search.study
            @user.save!
          end

          it 'displays request summary' do
            visit path
            expect(page).to have_content('Data for this search has been requested and is pending release.')
            expect(page).to have_content('Results: 41 participants returned')
            expect(page).not_to have_content('Participants filtered by the folowing conditions')
            expect(page).not_to have_content(@question.text)

            find("a", :text => "Show request conditions").click
            expect(page).to have_content('Participants filtered by the folowing conditions')
            expect(page).to have_content(@question.text)

            expect(page).not_to have_content(@participant1.first_name)
            expect(page).not_to have_content(@participant1.last_name)
            expect(page).not_to have_content(@participant2.first_name)
            expect(page).not_to have_content(@participant2.last_name)
          end

          it 'does not allow to update a request' do
            visit path
            find("a", :text => "Show request conditions").click
            within '#search-conditions-container' do
              expect(page).not_to have_link('Edit')
              expect(page).not_to have_link('Add condition')
              expect(page).not_to have_link('Add group of conditions')
              expect(page).not_to have_button('Delete')
            end
          end

          include_examples 'shared examples for comments'
          include_examples 'shared examples for copying a request'
        end
      end
    end
  end
end
