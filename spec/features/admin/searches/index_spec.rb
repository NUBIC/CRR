require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'listing requests', type: :feature do
    let(:path)            { admin_searches_path }
    let(:submitted_path)  { admin_searches_path(state: 'data_requested') }
    let(:released_path)   { admin_searches_path(state: 'data_released') }
    let(:expiring_path)   { admin_searches_path(state: 'data_expiring') }

    describe 'unauthorized access' do
      describe 'public account access' do
        include_context 'user login'

        it 'redirects user to admin login page from all requests page' do
          visit path
          expect(page).to have_current_path(new_user_session_path)
          expect(page).to have_content('You need to sign in before continuing.')
        end

        it 'redirects user to admin login page from submitted requests page' do
          visit submitted_path
          expect(page).to have_current_path(new_user_session_path)
          expect(page).to have_content('You need to sign in before continuing.')
        end

        it 'redirects user to admin login page from released requests page' do
          visit released_path
          expect(page).to have_current_path(new_user_session_path)
          expect(page).to have_content('You need to sign in before continuing.')
        end

        it 'redirects user to admin login page from expiring requests page' do
          visit expiring_path
          expect(page).to have_current_path(new_user_session_path)
          expect(page).to have_content('You need to sign in before continuing.')
        end
      end
    end

    describe 'authorized access' do
      describe 'admin access' do
        include_context 'admin login'

        before(:each) do
          @submitted_request  = FactoryGirl.create(:submitted_request)
          @released_request   = FactoryGirl.create(:released_request)
          @expiring_request   = FactoryGirl.create(:expiring_request)
          @expired_request    = FactoryGirl.create(:expired_request)

          @requests = [@submitted_request, @released_request, @expiring_request, @expired_request]
        end

        describe 'all requests page' do
          it 'displays a list requests' do
            visit path
            @requests.each do |request|
              expect(page).to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).to have_content(request.study.display_name)
              expect(page).to have_content(request.request_date)
              expect(page).to have_content(request.process_date)
              expect(page).to have_content(request.warning_date)
              expect(page).to have_content(request.end_date)
            end
          end

          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end

        describe 'submitted requests page' do
          it 'displays a list of requests' do
            visit submitted_path
            expect(page).to have_link(@submitted_request.display_name, href: admin_search_path(id: @submitted_request.id))
            expect(page).to have_content(@submitted_request.study.display_name)
            expect(page).to have_content(@submitted_request.request_date)

            requests = [@released_request, @expiring_request, @expired_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
            end
          end

          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end

        describe 'released requests page' do
          it 'displays a list of requests' do
            visit released_path
            requests = [@released_request, @expiring_request, @expired_request]
            requests.each do |request|
              expect(page).to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).to have_content(request.study.display_name)
              expect(page).to have_content(request.request_date)
              expect(page).to have_content(request.process_date)
              expect(page).to have_content(request.warning_date)
              expect(page).to have_content(request.end_date)
            end

            expect(page).not_to have_link(@submitted_request.display_name, href: admin_search_path(id: @submitted_request.id))
          end

          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end

        describe 'expiring requests page' do
          it 'displays a list of requests' do
            visit expiring_path

            requests = [@expiring_request]
            requests.each do |request|
              expect(page).to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).to have_content(request.study.display_name)
              expect(page).to have_content(request.request_date)
              expect(page).to have_content(request.process_date)
              expect(page).to have_content(request.warning_date)
              expect(page).to have_content(request.end_date)
            end

            requests = [@submitted_request, @released_request, @expired_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).not_to have_content(request.study.display_name)
            end
          end

          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end
      end

      describe 'researcher access' do
        include_context 'researcher login'

        before(:each) do
          @submitted_request  = FactoryGirl.create(:submitted_request)
          @released_request   = FactoryGirl.create(:released_request)
          @expiring_request   = FactoryGirl.create(:expiring_request)
          @expired_request    = FactoryGirl.create(:expired_request)

          @requests = [@submitted_request, @released_request, @expiring_request, @expired_request]
        end

        describe 'all requests page' do
          it 'does not display requests from other studies' do
            visit path
            @requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).not_to have_content(request.study.display_name)
            end
          end

          it 'displays requests from researcher`s studies' do
            @requests.each do |request|
              @user.studies << request.study
            end

            visit path
            @requests.each do |request|
              expect(page).to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).to have_content(request.study.display_name)
              expect(page).to have_content(request.request_date)
              expect(page).to have_content(request.process_date)
              expect(page).to have_content(request.warning_date)
              expect(page).to have_content(request.end_date)
            end
          end

          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end

        describe 'submitted requests page' do
          it 'does not display requests from other studies' do
            visit submitted_path
            expect(page).not_to have_link(@submitted_request.display_name, href: admin_search_path(id: @submitted_request.id))
            expect(page).not_to have_content(@submitted_request.study.display_name)

            requests = [@released_request, @expiring_request, @expired_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
            end
          end

          it 'displays a list of requests from researcher`s studies' do
            @requests.each do |request|
              @user.studies << request.study
            end

            visit submitted_path
            expect(page).to have_link(@submitted_request.display_name, href: admin_search_path(id: @submitted_request.id))
            expect(page).to have_content(@submitted_request.study.display_name)
            expect(page).to have_content(@submitted_request.request_date)

            requests = [@released_request, @expiring_request, @expired_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
            end
          end

          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end

        describe 'released requests page' do
          it 'does not display requests from other studies' do
            visit released_path
            requests = [@released_request, @expiring_request, @expired_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).not_to have_content(request.study.display_name)
            end

            expect(page).not_to have_link(@submitted_request.display_name, href: admin_search_path(id: @submitted_request.id))
          end

          it 'displays requests from researcher`s studies' do
            @requests.each do |request|
              @user.studies << request.study
            end

            visit released_path
            requests = [@released_request, @expiring_request, @expired_request]
            requests.each do |request|
              expect(page).to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).to have_content(request.study.display_name)
              expect(page).to have_content(request.request_date)
              expect(page).to have_content(request.process_date)
              expect(page).to have_content(request.warning_date)
              expect(page).to have_content(request.end_date)
            end

            expect(page).not_to have_link(@submitted_request.display_name, href: admin_search_path(id: @submitted_request.id))
          end


          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end

        describe 'expiring requests page' do
          it 'does not display requests from other studies' do
            visit expiring_path

            requests = [@expiring_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).not_to have_content(request.study.display_name)
            end

            requests = [@submitted_request, @released_request, @expired_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).not_to have_content(request.study.display_name)
            end
          end

          it 'displays requests from researcher`s studies' do
            @requests.each do |request|
              @user.studies << request.study
            end

            visit expiring_path
            requests = [@expiring_request]
            requests.each do |request|
              expect(page).to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).to have_content(request.study.display_name)
              expect(page).to have_content(request.request_date)
              expect(page).to have_content(request.process_date)
              expect(page).to have_content(request.warning_date)
              expect(page).to have_content(request.end_date)
            end

            requests = [@submitted_request, @released_request, @expired_request]
            requests.each do |request|
              expect(page).not_to have_link(request.display_name, href: admin_search_path(id: request.id))
              expect(page).not_to have_content(request.study.display_name)
            end
          end

          it 'allows to add a new request' do
            visit path
            expect(page).to have_link('Build a request', href: new_admin_search_path)
          end
        end
      end
    end
  end
end
