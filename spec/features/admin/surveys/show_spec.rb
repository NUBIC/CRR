require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'updating a survey', type: :feature do
    let(:survey)                    { FactoryBot.create(:survey, multiple_section: false) }
    let(:section)                   { survey.sections.first }
    let(:multiple_sections_survey)  { FactoryBot.create(:survey, multiple_section: true) }

    let(:path)      { admin_survey_path(survey.id) }

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

        it 'should display survey information' do
          visit path
          expect(page).to have_content("Title: #{survey.title}")
          expect(page).not_to have_content('Tier 2 data')

          survey.tier_2 = true
          survey.save!
          visit path
          expect(page).to have_content('Tier 2 data')
        end

        context 'deactivated survey' do
          before(:each) do
            survey.deactivate
            survey.save!
          end

          it 'should be editable' do
            visit path
            expect(page).to have_link('Edit', href: edit_admin_survey_path(survey.id))
          end

          it 'should be deletable' do
            visit path
            expect(page).to have_button('Delete')
          end

          it 'should not allow to add section for one-section survey' do
            visit path
            expect(page).not_to have_link('Add Section', href: new_admin_section_path)
          end

          it 'cannot be deactivated' do
            visit path
            expect(page).not_to have_button('Deactivate')
          end

          describe 'activating surveys' do
            it 'should not be allowed if survey has no sections' do
              survey.sections.destroy_all

              visit path
              click_on('Activate')
              expect(page).to have_current_path(path)
              expect(survey.reload).not_to be_active
              expect(page).to have_content('Survey must have at least one section')
            end

            it 'should not be allowed if survey has no questions' do
              visit path
              click_on('Activate')
              expect(page).to have_current_path(path)
              expect(survey.reload).not_to be_active
              expect(page).to have_content('Survey sections must have at least one question')
            end

            it 'should not be allowed if multiple choice question has no answers' do
              Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
                question  = survey.sections.first.questions.create(text: "test#{i}", response_type: response_type)
              end
              visit path
              click_on('Activate')
              expect(page).to have_current_path(path)
              expect(survey.reload).not_to be_active
              expect(page).to have_content('Survey multiple choice questions must have at least 2 answers')
            end

            it 'should be allowed for valid surveys', js: true do
              Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
                question  = survey.sections.first.questions.create(text: "test#{i}", response_type: response_type)
                (1..2).each do |j|
                  answer = question.answers.create(text: "answer_#{j}")
                end
              end
              visit path
              expect(page).to have_button('Activate')

              click_on('Activate')
              expect(page).to have_current_path(path)
              expect(survey.reload).to be_active
            end
          end

          describe 'editing sections', js: true do
            it 'should allow to edit sections' do
              visit path
              expect(page).to have_link('Edit', href: edit_admin_section_path(survey.sections.first.id))
              within('.tab-content') do
                click_on('Edit')
              end
              expect(page).to have_current_path(path)
              expect(page).to have_field('Title', with: section.title)
              new_title = "#{section.title} - updated"

              within('#admin_edit_section') do
                fill_in('Title', with: new_title)
                click_on('Update')
              end

              expect(page).to have_current_path(path)
              expect(page).to have_content(new_title)
            end

            it 'should allow to cancel editing sections', js: true do
              visit path
              new_title = "#{section.title} - updated"

              within('.tab-content') do
                click_on('Edit')
              end

              within('#admin_edit_section') do
                expect(page).to have_current_path(path)
                expect(page).to have_field('Title', with: section.title)
                fill_in('Title', with: new_title)
                click_on('Cancel')
              end

              expect(page).to have_current_path(path)
              expect(page).not_to have_content(new_title)
              expect(page).to have_content(section.title)
            end

            it 'should provide client side validation', js: true do
              visit path
              within('.tab-content') do
                click_on('Edit')
              end
              within('#admin_edit_section') do
                fill_in('Title', with: '')
                click_on('Update')
                expect(find(".controls label[for='section_title']")).to have_content('This field is required')
              end
            end
          end

          context 'survey with multiple sections' do
            let(:path) { admin_survey_path(multiple_sections_survey.id) }

            describe 'creating sections' do
              it 'allows to add section', js: true do
                visit path
                expect(page).to have_link('Add Section', href: new_admin_section_path(survey_id: multiple_sections_survey.id))

                click_on('Add Section')
                expect(page).to have_current_path(path)
                expect(page).to have_field('Title')
                expect(page).to have_field('Display order')

                fill_in('Title', with: 'Test section')
                click_on('Create')

                expect(page).to have_current_path(path)
                expect(page).to have_content('Section: Test section')
                expect(page).to have_link('Test section', href: "#section_#{multiple_sections_survey.sections.last.id}")
              end

              it 'provides client side validation', js: true do
                visit path
                click_on('Add Section')
                fill_in('Title', with: '')
                click_on('Create')
                expect(find(".controls label[for='section_title']")).to have_content('This field is required')
              end
            end

            it 'should allow to switch between sections', js: true do
              (1..3).each do |i|
                multiple_sections_survey.sections.create(title: "test_#{i}")
              end
              expect(multiple_sections_survey.sections.size).to eq 3

              visit path
              multiple_sections_survey.sections.each do |section|
                expect(page).to have_link(section.title, href: "#section_#{section.id}")

                click_on section.title
                expect(page).to have_current_path(path)
                expect(page).to have_content("Section: #{section.title}")
              end
            end

            it 'should allow to delete sections', js: true do
              (1..3).each do |i|
                multiple_sections_survey.sections.create(title: "test_#{i}")
              end

              visit path
              within '.tab-content' do
                first_section = multiple_sections_survey.sections.first
                expect(page).to have_button('Delete')

                click_on 'Delete'
                expect(page).to have_current_path(path)
                expect(page).not_to have_link(first_section.title)
              end
            end
          end

          describe 'adding a question' do
            it 'should render new question form', js: true do
              visit path
              expect(survey.sections.first.questions.size).to eq 0
              expect(page).to have_link('Add Question', href: new_admin_question_path(section_id: survey.sections.first.id))

              click_on 'Add Question'
              expect(page).to have_current_path(path)
              expect(page).to have_field('question_text')
              expect(page).to have_field('question_response_type')
              expect(page).to have_field('Code')
              expect(page).to have_field('Display order')
              expect(page).to have_field('Mandatory')

              click_on 'Cancel'
              expect(page).to have_current_path(path)
            end

            Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
              response_type_name = Question::VIEW_RESPONSE_TYPE_TRANSLATION[response_type]

              it "should allow to add a question of type #{response_type_name}", js: true do
                question_text = "test_#{response_type_name}"
                expect(survey.sections.first.questions.size).to eq 0

                visit path
                click_on 'Add Question'
                fill_in('question_text', with: question_text)
                select(response_type_name, from: 'question_response_type')
                click_on('Update')
                expect(page).to have_current_path(path)
                expect(page).to have_content(question_text)

                expect(survey.reload.sections.first.questions.size).to eq 1
                question = survey.sections.first.questions.first
                expect(page).to have_selector("#q_#{question.id}")

                within "#q_#{question.id}" do
                  expect(page).to have_content(question_text)
                  expect(page).to have_content("Type: #{response_type_name}")
                  if ['pick_one', 'pick_many'].include?(response_type)
                    expect(page).to have_link('Add Answer')
                  else
                    expect(page).not_to have_link('Add Answer')
                  end
                end
              end
            end

            it 'should provide client side validation', js: true do
              visit path
              click_on 'Add Question'
              fill_in('question_text', with: '')
              click_on('Update')
              expect(find("label[for='question_text']")).to have_content('This field is required')
            end
          end

          Question::VALID_RESPONSE_TYPES.each do |response_type|
            response_type_name = Question::VIEW_RESPONSE_TYPE_TRANSLATION[response_type]
            question_text       = "test_#{response_type_name}"
            new_question_text   = "#{question_text} - updated"
            answer_text         = "test_#{response_type_name}_answer"

            it "should allow to edit a question of type #{response_type_name}", js: true do
              question = survey.sections.first.questions.create(text: question_text, response_type: response_type)
              visit path
              within "#q_#{question.id}" do
                expect(page).to have_link('Edit', href: edit_admin_question_path(question.id))
                click_on('Edit')
                fill_in('question_text', with: new_question_text)
                click_on('Update')
              end

              expect(page).to have_current_path(path)
              expect(page).to have_content(new_question_text)

              expect(survey.reload.sections.first.questions.size).to eq 1
              expect(page).to have_selector("#q_#{question.id}")
            end

            it "should provide client side validation for a a question of type #{response_type_name}", js: true do
              question = survey.sections.first.questions.create(text: question_text, response_type: response_type)
              visit path
              within "#q_#{question.id}" do
                click_on('Edit')
                fill_in('question_text', with: '')
                click_on('Update')
                expect(find("label[for='question_text']")).to have_content('This field is required')
              end
            end

            it "should allow to delete a #{response_type} question", js: true do
              question = survey.sections.first.questions.create(text: question_text, response_type: response_type)
              visit path
              within "#q_#{question.id}" do
                expect(page).to have_button('Delete')
                click_on('Delete')
              end

              expect(page).not_to have_selector("#q_#{question.id}")
              expect(page).not_to have_content(question_text)
            end

            if ['pick_one', 'pick_many'].include?(response_type)
              describe "adding an answer for #{response_type} question" do
                it "should allow to add a new answer", js: true do
                  question = survey.sections.first.questions.create(text: question_text, response_type: response_type)
                  visit path
                  within "#q_#{question.id}" do
                    expect(page).to have_link('Add Answer')

                    click_on 'Add Answer'
                    expect(page).to have_field('answer_text')
                    expect(page).to have_field('answer_code')

                    fill_in('answer_text', with: answer_text)
                    click_on('Update')

                    expect(page).to have_current_path(path)
                    expect(page).to have_content(answer_text)
                    expect(question.answers.size).to eq 1
                  end
                end

                it 'should provide client side validation', js: true do
                  question = survey.sections.first.questions.create(text: question_text, response_type: response_type)
                  visit path
                  within "#q_#{question.id}" do
                    click_on 'Add Answer'
                    fill_in('answer_text', with: '')
                    click_on('Update')

                    expect(find("label[for='answer_text']")).to have_content('This field is required')
                  end
                end
              end

              describe "editing an answer for #{response_type} question" do
                before(:each) do
                  @question = survey.sections.first.questions.create(text: question_text, response_type: response_type)
                  @answer   = @question.answers.create(text: answer_text)
                end

                it 'allows to edit an answer', js: true do
                  new_answer_text = "#{answer_text} - updated"

                  visit path
                  within "#q_#{@question.id} #answer_#{@answer.id}" do
                    expect(page).to have_link('Edit', href: edit_admin_answer_path(@answer.id))

                    click_on 'Edit'
                    expect(page).to have_field('answer_text')
                    expect(page).to have_field('answer_code')

                    fill_in('answer_text', with: new_answer_text)
                    click_on('Update')

                    expect(page).to have_current_path(path)
                    expect(page).to have_content(new_answer_text)
                    expect(@question.answers.size).to eq 1
                  end
                end

                it 'should provide client side validation', js: true do
                  visit path
                  within "#q_#{@question.id} #answer_#{@answer.id}" do
                    click_on 'Edit'
                    fill_in('answer_text', with: '')
                    click_on('Update')

                    expect(find("label[for='answer_text']")).to have_content('This field is required')
                  end
                end

                it 'should allow to delete an answer', js: true do
                  visit path
                  within "#q_#{@question.id} #answer_#{@answer.id}" do
                    expect(page).to have_button('Delete')
                    click_on('Delete')
                  end

                  expect(page).not_to have_content(answer_text)
                  expect(@question.reload.answers.size).to eq 0
                end
              end
            else
              it "should not allow to add answer for #{response_type} question", js: true do
                question = survey.sections.first.questions.create(text: question_text, response_type: response_type)
                visit path
                within "#q_#{question.id}" do
                  expect(page).not_to have_link('Add Answer')
                end
              end
            end
          end
        end

        context 'activated survey' do
          before(:each) do
            Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
              question  = survey.sections.first.questions.create(text: "test#{i}", response_type: response_type)
              (1..2).each do |j|
                answer = question.answers.create(text: "answer_#{j}")
              end
            end
            survey.activate
            survey.save!
          end

          it 'should not be editable' do
            visit path
            expect(page).not_to have_link('Edit', href: edit_admin_survey_path(survey.id))
          end

          it 'should not be deletable' do
            survey.activate
            survey.save!

            visit path
            expect(page).not_to have_link('Edit', href: edit_admin_survey_path(survey.id))
            visit path
            expect(page).not_to have_button('Delete')
          end

          it 'can be deactivated' do
            visit path
            expect(page).to have_button('Deactivate')

            click_on('Deactivate')
            expect(page).to have_current_path(path)
            expect(survey.reload).to be_inactive
          end

          it 'cannot be activated' do
            visit path
            expect(page).not_to have_button('Activate')
          end

          it 'should not allow to rename sections' do
            visit path
            expect(page).not_to have_link('Edit', href: edit_admin_section_path(survey.sections.first.id))
          end

          it 'should not allow to add section' do
            visit path
            expect(page).not_to have_link('Add Section', href: new_admin_section_path)

            visit admin_survey_path(multiple_sections_survey.id)
            expect(page).not_to have_link('Add Section', href: new_admin_section_path)
          end
        end

        it 'should allow to see a preview', js: true do
          Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
            question  = survey.sections.first.questions.create(text: "test#{i}", response_type: response_type)
            (1..2).each do |j|
              answer = question.answers.create(text: "answer_#{j}")
            end
          end

          visit path
          click_on('Preview')

          expect(page).to have_current_path(path)
          expect(page).to have_link("Back to #{survey.title}", href: admin_survey_path(survey.id))
          expect(page).not_to have_link('Preview', href: preview_admin_survey_path(survey.id))
          expect(page).not_to have_link('Edit', href: edit_admin_survey_path(survey.id))
          expect(page).not_to have_button('Delete')
          expect(page).not_to have_button('Activate')
          expect(page).not_to have_button('Deactivate')

          survey.sections.first.questions.each do |question|
            expect(page).to have_content(question.text)
          end
        end
      end
    end
  end
end
