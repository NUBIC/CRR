require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.shared_examples 'shared requests examples' do
    it 'provides server side validation' do
      visit path
      click_on('Start')
      expect(page).to have_content("Study can't be blank")
    end

    it 'provides client side validation', js: true do
      visit path
      click_on('Start')
      expect(find(".controls label[for='search_study_id']")).to have_content('This field is required')
    end

    it 'does not include inactive studies in available options' do
      set_inactive_studies = inactive_studies
      visit path
      options = inactive_studies.map{|s| "#{s.display_name} - #{s.irb_number}"} + ['']
      expect(page).not_to have_select('Study', options: options)
    end
  end

  RSpec.describe 'creating a new request', type: :feature do
    let(:path)            { new_admin_search_path }
    let(:inactive_studies) {
      studies = []
      (0..3).each{ studies << FactoryGirl.create(:study) }
      studies
    }
    let(:active_studies) {
      studies = []
      (0..3).each{ studies << FactoryGirl.create(:study, state: 'active') }
      studies
    }
    describe 'unauthorized access' do
      describe 'public account access' do
        include_context 'user login'

        it 'redirects user to admin login page from all requests page' do
          visit path
          expect(page).to have_current_path(new_user_session_path)
          expect(page).to have_content('You need to sign in before continuing.')
        end
      end
    end

    describe 'authorized access' do
      let(:options) {
        active_studies.map{|s| "#{s.display_name} - #{s.irb_number}"} + ['']
      }
      describe 'admin access' do
        include_context 'admin login'
        include_examples 'shared requests examples'

        before(:each) do
          set_active_studies = active_studies
        end

        it 'includes active studies in available options' do
          visit path
          expect(page).to have_select('Study', options: options)
        end

        it 'allows to create a request', js: true do
          visit path
          select(options.first, from: 'Study')
          fill_in('Name', with: 'test request #1')
          click_on('Start')

          expect(page).to have_content('test request #1')
          expect(page).to have_current_path(admin_search_path(Search.last.id))
        end
      end

      describe 'researcher access' do
        include_context 'researcher login'
        include_examples 'shared requests examples'

        before(:each) do
          set_active_studies    = active_studies
          set_inactive_studies  = inactive_studies
        end

        it 'does not include studies not linked with researcher in available options' do
          visit path
          expect(page).not_to have_select('Study', options: options)
        end

        it 'does includes studies not linked with researcher in available options' do
          active_studies.each do |study|
            @user.studies << study
          end
          visit path
          expect(page).to have_select('Study', options: options)
        end

        it 'allows to create a request', js: true do
          active_studies.each do |study|
            @user.studies << study
          end
          visit path
          select(options.first, from: 'Study')
          fill_in('Name', with: 'test request #1')
          click_on('Start')

          expect(page).to have_current_path(admin_search_path(Search.last.id))
          expect(page).to have_content('test request #1')
        end
      end
    end
  end
end
