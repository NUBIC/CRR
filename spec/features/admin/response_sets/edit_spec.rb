require 'rails_helper'
require 'support/shared_context'

module Admin
  RSpec.describe 'filling in a survey', type: :feature do
    let(:participant) { FactoryBot.create(:participant, stage: 'approved') }
    let!(:survey)      {
      survey        = FactoryBot.create(:survey)
      section       = survey.sections.create(title: 'section 1')
      new_question  = section.questions.create(text: "question #{@response_type}", response_type: response_type)
      if new_question.multiple_choice?
        3.times do |i|
          new_question.answers.create(text: "answer #{i}")
        end
      end
      survey.activate
      survey.save!
      survey
    }
    let!(:question)    { survey.sections.first.questions.first }
    let!(:response_set){ participant.response_sets.create(survey: survey) }
    let!(:path)        { edit_admin_response_set_path(response_set) }

    describe 'unauthorized access' do
      let(:response_type) { Question::VALID_RESPONSE_TYPES.sample }
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

        Question::VALID_RESPONSE_TYPES.each do |response_type|
          describe "with #{response_type} response_type" do
            let(:response_type) { response_type }

            it "renders a #{response_type}", js: true do
              expect(page).to have_content(question.text)
            end

            unless response_type == 'none'
              it "allows to answer a #{response_type}", js: true do
                answer_text = nil
                visit path
                if question.true_date?
                  answer_text = Date.today.to_s
                  find("input[name='response_set[q_#{question.id}]']").click # to avoid weird reformatting of the date
                  fill_in(question.text, with: answer_text)
                elsif question.file_upload?
                  answer_text  = 'README.md'
                  attach_file(question.text, Rails.root.join(answer_text))
                elsif question.pick_many?
                  answer_text  = 'answer 2'
                  check answer_text
                elsif question.pick_one?
                  answer_text  = 'answer 2'
                  choose answer_text
                elsif question.number?
                  answer_text  = '99'
                  fill_in(question.text, with: answer_text)
                else
                  answer_text = 'hello world'
                  fill_in(question.text, with: answer_text)
                end
                click_on('Submit')
                expect(page).to have_current_path(admin_participant_path(participant, tab: 'surveys'))
                expect(find('table#participant_survey_list tbody')).to have_selector('tr', count: 1)
                expect(find('table#participant_survey_list tbody tr')).to have_content('Complete')
                click_on(survey.title)

                if question.true_date?
                  expect(find_field(question.text).value).to eq answer_text
                elsif question.file_upload?
                  within('div[data-response-set-upload-file-fields]') do
                    expect(page).to have_link(answer_text)
                    expect(page).to have_link('Remove')

                    click_link(answer_text)
                    expect(DownloadHelpers::download_content).to eq File.read(answer_text)

                    click_link('Remove')
                    expect(page).not_to have_link(answer_text)
                    expect(page).to have_field(question.text, type: 'file')
                  end
                elsif question.multiple_choice?
                  question.answers.each do |answer|
                    if answer.text == answer_text
                      expect(page).to have_field(answer.text, checked: true)
                    else
                      expect(page).to have_field(answer.text, checked: false)
                    end
                  end
                elsif question.number?
                  expect(find_field(question.text).value).to eq answer_text
                else
                  expect(find_field(question.text).value).to eq answer_text
                end
              end

              it "validates mandatory #{response_type} question", js: true do
                question.is_mandatory = true
                question.save
                visit path
                expect(find("div.response_set_q_#{question.id}")).to have_content('Required field')
                click_on('Submit')
                expect(page).to have_current_path(path)
                expect(page).to have_content('You missed something! See below')
                expect(find("div.response_set_q_#{question.id}")).to have_content('This field is required.')
              end

              if ['date', 'birth_date'].include? response_type
                it "validates #{response_type} answer format", js: true do
                  visit path
                  find("input[name='response_set[q_#{question.id}]']").click # to avoid weird reformatting of the date
                  fill_in(question.text, with: '2001-02-03')
                  click_on('Submit')
                  expect(page).to have_current_path(path)
                  expect(page).to have_content("Please specify a valid date in 'MM/DD/YYYY' format.")
                end
              end
            end
          end
        end
      end
    end
  end
end
