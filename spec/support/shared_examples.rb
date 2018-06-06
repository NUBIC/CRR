require 'support/helpers'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.shared_examples 'shared examples for comments' do
  describe 'adding a comment' do
    it 'provides client-side validation', js: true do
      visit path
      within 'div#comments' do
        expect(page).to have_field('comment_content')
        fill_in('comment_content', with: '')
        click_on('Save')
        expect(find("label[for='comment_content']")).to have_content('This field is required')
      end
    end

    it 'allows do add a comment', js: true do
      visit path
      within 'div#comments' do
        expect(page).to have_field('comment_content')
        fill_in('comment_content', with: 'hello')
        click_on('Save')
      end
      expect(page).to have_current_path(path)
      within 'div#comments' do
        expect(page).to have_content('hello')
        expect(page).to have_content(@user.full_name)
      end
    end
  end
end

RSpec.shared_examples 'shared examples for copying a request' do
  describe 'copying a request' do
    before :each do
      set_surveys
    end

    it 'does not alow to copy request without conditions' do
      pending 'TODO'
      fail
    end

    it 'renders list of available studies' do
      pending 'TODO'
      fail
    end

    it 'creates a new request with same conditions' do
      pending 'TODO'
      fail
    end
  end
end

RSpec.shared_examples 'shared examples for search conditions' do
  describe 'adding a condition' do
    before :each do
      set_surveys
    end

    it 'renders a list of questions', js: true do
      visit path
      click_on('Add condition')
      expect(page).to have_selector('.search_condition_group_new_condition')
      within '.search_condition_group_new_condition' do
        expect(page).to have_selector('form#new_search_condition')
        expect(page).to have_selector('.select2')

        find('span.select2').click
      end
      within('.select2-container--open ul') do
        expect(page).not_to have_selector('span.user-circle')
        @questions.each do |question|
          if question.label? || question.file_upload?
            expect(page).not_to have_content("#{@survey.title} - #{question.section.title} - #{question.text}")
          else
            expect(page).to have_content("#{@survey.title} - #{question.section.title} - #{question.text}")
          end
        end
      end
    end

    it 'indicates questions from active surveys', js: true do
      @survey.activate
      @survey.save!

      visit path
      click_on('Add condition')
      expect(page).to have_selector('.search_condition_group_new_condition')

      within '.search_condition_group_new_condition' do
        find('span.select2').click
      end
      expect(page).to have_selector('.select2-results__option .user-circle') # make capybara wait till request is completed
      within '.select2-results' do
        all('.select2-container--open ul li.select2-results__option').each do |element|
          within element do
            expect(page).to have_selector('span.user-circle')
          end
        end
      end
    end

    describe 'using a question list popup' do
      it 'renders available questions', js: true do
        visit path
        click_on('Add condition')
        expect(page).to have_selector('.search_condition_group_new_condition')

        within '.search_condition_group_new_condition' do
          expect(page).to have_selector('a.question_lookup')
          find('a.question_lookup').click
        end

        expect(page).to have_selector('.question-modal-lookup')
        within('.question-modal-lookup') do
          expect(page).to have_content('Search survey questions')
          @questions.each do |question|
            if question.label? || question.file_upload?
              expect(page).not_to have_content(question.text)
            else
              expect(page).to have_content(question.section.survey.title)
              expect(page).to have_content(question.section.title)
              expect(page).to have_content(question.text)
              question.answers.each do |answer|
                expect(page).to have_content(answer.text)
              end
            end
          end
        end
      end

      Question::VALID_RESPONSE_TYPES.each_with_index do |response_type, i|
        unless ['none', 'file_upload'].include? response_type
          it "allows to select a #{response_type} question", js: true do
            question = @questions.select{ |q| q.response_type == response_type }.first
            visit path
            click_on('Add condition')
            expect(page).to have_selector('.search_condition_group_new_condition')

            find('.search_condition_group_new_condition a.question_lookup').click
            expect(page).to have_selector('.question_list')

            all('.question_list tr').each do |tr|
              next unless tr.has_content?(question.text)
              within tr do
                click_on('Select')
              end
            end
            within '.select2' do
              expect(page).to have_content("#{@survey.title} - #{question.section.title} - #{question.text}")
            end
          end
        end
      end
    end

    describe 'adding a date condition' do
      before :each do
        @question = @questions.select(&:true_date?).first
        @date_options     = SearchCondition::CALCULATED_DATE_UNITS.values
        operator_type     = SearchCondition.operator_type_for_question(@question)
        @operator_options = SearchCondition.operators_by_type(operator_type).map{
          |o| SearchCondition.operator_text( o[:symbol], operator_type)
        }
        visit path
        click_on('Add condition')
        expect(page).to have_selector('.search_condition_group_new_condition')

        find('span.select2').click
        expect(page).to have_selector('.search-condition-form')

        within '.select2-container--open ul' do
          find('.select2-container--open li', text: /#{@question.text}/).click
        end

        expect(page).to have_selector('.search-condition-values')
      end

      describe 'in "time ago" format', js: true do
        it 'renders condition fields' do
          expect(page).to have_selector('.search-condition-answers-form')

          expect(page).to have_select('search_condition_operator', options: @operator_options)
          expect(page).to have_field('search_condition_calculated_date_numbers_0')
          expect(page).to have_select('search_condition_calculated_date_units_0', options: @date_options)
          expect(page).not_to have_field('search_condition_values_0')

          select('between', from: 'search_condition_operator')
          expect(page).to have_field('search_condition_calculated_date_numbers_0')
          expect(page).to have_select('search_condition_calculated_date_units_0', options: @date_options)
          expect(page).not_to have_field('search_condition_values_0')
          expect(page).to have_field('search_condition_calculated_date_numbers_1')
          expect(page).to have_select('search_condition_calculated_date_units_1', options: @date_options)
          expect(page).not_to have_field('search_condition_values_1')

          select(@operator_options.first, from: 'search_condition_operator')
          expect(page).to have_field('search_condition_calculated_date_numbers_0')
          expect(page).to have_select('search_condition_calculated_date_units_0', options: @date_options)
          expect(page).not_to have_field('search_condition_values_0')
          expect(page).not_to have_field('search_condition_calculated_date_numbers_1')
          expect(page).not_to have_select('search_condition_calculated_date_units_1', options: @date_options)
          expect(page).not_to have_field('search_condition_values_1')
        end

        it 'provides client-side validation' do
          within '.search-condition-form' do
            click_on 'Save'
            expect(find("label[for='search_condition_calculated_date_numbers_0']")).to have_content('Please specify search value')
            fill_in('search_condition_calculated_date_numbers_0', with: 1)

            select('between', from: 'search_condition_operator')
            click_on 'Save'

            expect(find("label[for='search_condition_calculated_date_numbers_1']")).to have_content('Please specify search value')
            fill_in('search_condition_calculated_date_numbers_1', with: 3)
            click_on 'Save'
          end

          expect(page).to have_current_path(path)
          expect(page).not_to have_content('Please specify search value')
        end

        it 'allows to save search condition with unary operator' do
          within '.search-condition-form' do
            select(@operator_options.first, from: 'search_condition_operator')
            fill_in('search_condition_calculated_date_numbers_0', with: 1)
            select(@date_options.first, from: 'search_condition_calculated_date_units_0')

            click_on 'Save'
          end
          expect(page).to have_current_path(path)
          expect(page).to have_content(@question.text)
          expect(page).to have_content(@operator_options.first)
          expect(page).to have_content("1 #{@date_options.first}")
        end

        it 'allows to save search condition with binary operator' do
          within '.search-condition-form' do
            select('between', from: 'search_condition_operator')
            fill_in('search_condition_calculated_date_numbers_0', with: 1)
            select(@date_options.first, from: 'search_condition_calculated_date_units_0')
            fill_in('search_condition_calculated_date_numbers_1', with: 5)
            select(@date_options.last, from: 'search_condition_calculated_date_units_1')

            click_on 'Save'
          end
          expect(page).to have_current_path(path)
          expect(page).to have_content(@question.text)
          expect(page).to have_content('between')
          expect(page).to have_content("1 #{@date_options.first}")
          expect(page).to have_content("5 #{@date_options.last}")
        end
      end

      describe 'in date format', js: true do
        it 'renders condition fields' do
          expect(page).to have_selector('.search-condition-answers-form')
          click_on 'Use date format'

          expect(page).to have_select('search_condition_operator', options: @operator_options)
          expect(page).not_to have_field('search_condition_calculated_date_numbers_0')
          expect(page).not_to have_select('search_condition_calculated_date_units_0')
          expect(page).to have_field('search_condition_values_0')
          expect(page).not_to have_field('search_condition_calculated_date_numbers_1')
          expect(page).not_to have_select('search_condition_calculated_date_units_1')
          expect(page).not_to have_field('search_condition_values_1')

          select('between', from: 'search_condition_operator')
          expect(page).not_to have_field('search_condition_calculated_date_numbers_0')
          expect(page).not_to have_select('search_condition_calculated_date_units_0')
          expect(page).to have_field('search_condition_values_0')
          expect(page).not_to have_field('search_condition_calculated_date_numbers_1')
          expect(page).not_to have_select('search_condition_calculated_date_units_1')
          expect(page).to have_field('search_condition_values_1')

          select(@operator_options.first, from: 'search_condition_operator')
          expect(page).not_to have_field('search_condition_calculated_date_numbers_0')
          expect(page).not_to have_select('search_condition_calculated_date_units_0')
          expect(page).to have_field('search_condition_values_0')
          expect(page).not_to have_field('search_condition_calculated_date_numbers_1')
          expect(page).not_to have_select('search_condition_calculated_date_units_1')
          expect(page).not_to have_field('search_condition_values_1')
        end

        it 'provides client-side validation' do
          within '.search-condition-form' do
            click_on 'Use date format'
            click_on 'Save'
            expect(find("label[for='search_condition_values_0']")).to have_content('Please specify search value')
            fill_in('search_condition_values_0', with: 1)

            select('between', from: 'search_condition_operator')
            click_on 'Save'

            expect(find("label[for='search_condition_values_1']")).to have_content('Please specify search value')
            fill_in('search_condition_values_1', with: 3)
            click_on 'Save'
          end

          expect(page).to have_current_path(path)
          expect(page).not_to have_content('Please specify search value')
        end

        it 'allows to save search condition with unary operator' do
          within '.search-condition-form' do
            click_on 'Use date format'
            select(@operator_options.first, from: 'search_condition_operator')
            fill_in('search_condition_values_0', with: Date.today)
            click_on 'Save'
          end
          expect(page).to have_current_path(path)
          expect(page).to have_content(@question.text)
          expect(page).to have_content(@operator_options.first)
          expect(page).to have_content(Date.today)
        end

        it 'allows to save search condition with binary operator' do
          within '.search-condition-form' do
            click_on 'Use date format'
            select('between', from: 'search_condition_operator')
            fill_in('search_condition_values_0', with: Date.today)
            fill_in('search_condition_values_1', with: Date.tomorrow)

            click_on 'Save'
          end
          expect(page).to have_current_path(path)
          expect(page).to have_content(@question.text)
          expect(page).to have_content('between')
          expect(page).to have_content(Date.today)
          expect(page).to have_content(Date.tomorrow)
        end
      end
    end

    describe 'adding a short text condition', js: true do
      before :each do
        @question = @questions.select(&:short_text?).first
        operator_type     = SearchCondition.operator_type_for_question(@question)
        @operator_options = SearchCondition.operators_by_type(operator_type).map{
          |o| SearchCondition.operator_text( o[:symbol], operator_type)
        }
        visit path
        click_on('Add condition')
        expect(page).to have_selector('.search_condition_group_new_condition')

        find('span.select2').click
        expect(page).to have_selector('.search-condition-form')

        within '.select2-container--open ul' do
          find('.select2-container--open li', text: /#{@question.text}/).click
        end

        expect(page).to have_selector('.search-condition-values')
      end

      it 'renders condition fields' do
        expect(page).to have_selector('.search-condition-answers-form')
        expect(page).to have_select('search_condition_operator', options: @operator_options)
        expect(page).to have_field('search_condition_values_0')
      end

      it 'provides client-side validation' do
        within '.search-condition-form' do
          click_on 'Save'
          expect(find("label[for='search_condition_values_0']")).to have_content('Please specify search value')
          fill_in('search_condition_values_0', with: 'test')
          click_on 'Save'
        end

        expect(page).to have_current_path(path)
        expect(page).not_to have_content('Please specify search value')
      end

      it 'allows to save search condition operator' do
        within '.search-condition-form' do
          select(@operator_options.first, from: 'search_condition_operator')
          fill_in('search_condition_values_0', with: 'test')
          click_on 'Save'
        end
        expect(page).to have_current_path(path)
        expect(page).to have_content(@question.text)
        expect(page).to have_content(@operator_options.first)
        expect(page).to have_content("test")
      end
    end

    describe 'adding a long text condition', js: true do
      before :each do
        @question = @questions.select(&:long_text?).first
        operator_type     = SearchCondition.operator_type_for_question(@question)
        @operator_options = SearchCondition.operators_by_type(operator_type).map{
          |o| SearchCondition.operator_text( o[:symbol], operator_type)
        }
        visit path
        click_on('Add condition')
        expect(page).to have_selector('.search_condition_group_new_condition')

        find('span.select2').click
        expect(page).to have_selector('.search-condition-form')

        within '.select2-container--open ul' do
          find('.select2-container--open li', text: /#{@question.text}/).click
        end

        expect(page).to have_selector('.search-condition-values')
      end

      it 'renders condition fields' do
        expect(page).to have_selector('.search-condition-answers-form')
        expect(page).to have_select('search_condition_operator', options: @operator_options)
        expect(page).to have_field('search_condition_values_0')
      end

      it 'provides client-side validation' do
        within '.search-condition-form' do
          click_on 'Save'
          expect(find("label[for='search_condition_values_0']")).to have_content('Please specify search value')
          fill_in('search_condition_values_0', with: 'test')
          click_on 'Save'
        end

        expect(page).to have_current_path(path)
        expect(page).not_to have_content('Please specify search value')
      end

      it 'allows to save search condition operator' do
        within '.search-condition-form' do
          select(@operator_options.first, from: 'search_condition_operator')
          fill_in('search_condition_values_0', with: 'test')
          click_on 'Save'
        end
        expect(page).to have_current_path(path)
        expect(page).to have_content(@question.text)
        expect(page).to have_content(@operator_options.first)
        expect(page).to have_content("test")
      end
    end

    describe 'adding a number condition', js: true do
      before :each do
        @question = @questions.select(&:number?).first
        operator_type     = SearchCondition.operator_type_for_question(@question)
        @operator_options = SearchCondition.operators_by_type(operator_type).map{
          |o| SearchCondition.operator_text( o[:symbol], operator_type)
        }
        visit path
        click_on('Add condition')
        expect(page).to have_selector('.search_condition_group_new_condition')

        find('span.select2').click
        expect(page).to have_selector('.search-condition-form')

        within '.select2-container--open ul' do
          find('.select2-container--open li', text: /#{@question.text}/).click
        end

        expect(page).to have_selector('.search-condition-values')
      end

      it 'renders condition fields' do
        expect(page).to have_selector('.search-condition-answers-form')

        expect(page).to have_select('search_condition_operator', options: @operator_options)
        expect(page).not_to have_field('search_condition_calculated_date_numbers_0')
        expect(page).not_to have_select('search_condition_calculated_date_units_0', options: @date_options)
        expect(page).to have_field('search_condition_values_0')

        select('between', from: 'search_condition_operator')
        expect(page).not_to have_field('search_condition_calculated_date_numbers_0')
        expect(page).not_to have_select('search_condition_calculated_date_units_0', options: @date_options)
        expect(page).to have_field('search_condition_values_0')
        expect(page).not_to have_field('search_condition_calculated_date_numbers_1')
        expect(page).not_to have_select('search_condition_calculated_date_units_1', options: @date_options)
        expect(page).to have_field('search_condition_values_1')

        select(@operator_options.first, from: 'search_condition_operator')
        expect(page).not_to have_field('search_condition_calculated_date_numbers_0')
        expect(page).not_to have_select('search_condition_calculated_date_units_0', options: @date_options)
        expect(page).to have_field('search_condition_values_0')
        expect(page).not_to have_field('search_condition_calculated_date_numbers_1')
        expect(page).not_to have_select('search_condition_calculated_date_units_1', options: @date_options)
        expect(page).not_to have_field('search_condition_values_1')
      end

      it 'provides client-side validation' do
        within '.search-condition-form' do
          click_on 'Save'
          expect(find("label[for='search_condition_values_0']")).to have_content('Please specify search value')
          fill_in('search_condition_values_0', with: 1)

          select('between', from: 'search_condition_operator')
          click_on 'Save'

          expect(find("label[for='search_condition_values_1']")).to have_content('Please specify search value')
          fill_in('search_condition_values_1', with: 3)
          click_on 'Save'
        end

        expect(page).to have_current_path(path)
        expect(page).not_to have_content('Please specify search value')
      end

      it 'allows to save search condition with unary operator' do
        within '.search-condition-form' do
          select(@operator_options.first, from: 'search_condition_operator')
          fill_in('search_condition_values_0', with: 1)
          click_on 'Save'
        end
        expect(page).to have_current_path(path)
        expect(page).to have_content(@question.text)
        expect(page).to have_content(@operator_options.first)
        expect(page).to have_content("1")
      end

      it 'allows to save search condition with binary operator' do
        within '.search-condition-form' do
          select('between', from: 'search_condition_operator')
          fill_in('search_condition_values_0', with: 1)
          fill_in('search_condition_values_1', with: 5)
          click_on 'Save'
        end
        expect(page).to have_current_path(path)
        expect(page).to have_content(@question.text)
        expect(page).to have_content('between')
        expect(page).to have_content("1")
        expect(page).to have_content("5")
      end
    end

    describe 'adding a multiple choice condition', js: true do
      before :each do
        @question = @questions.select(&:multiple_choice?).first
        operator_type     = SearchCondition.operator_type_for_question(@question)
        @operator_options = SearchCondition.operators_by_type(operator_type).map{
          |o| SearchCondition.operator_text( o[:symbol], operator_type)
        }
        visit path
        click_on('Add condition')
        expect(page).to have_selector('.search_condition_group_new_condition')

        find('span.select2').click
        expect(page).to have_selector('.search-condition-form')

        within '.select2-container--open ul' do
          find('.select2-container--open li', text: /#{@question.text}/).click
        end

        expect(page).to have_selector('.search-condition-values')
      end

      it 'renders available answers' do
        expect(page).to have_selector('.search-condition-answers-form')
        expect(page).to have_select('search_condition_operator', options: @operator_options)
        @question.answers.each do |answer|
          expect(page).to have_unchecked_field(answer.text)
        end
      end

      it 'provides client side validation' do
        within '.search-condition-form' do
          click_on 'Save'
        end
        expect(page).to have_content("Values can't be blank")

        within '.search-condition-form' do
          all('label.checkbox').first.click
          click_on 'Save'
        end
        expect(page).to have_current_path(path)
        expect(page).not_to have_content("Values can't be blank")
      end

      it 'allows to select multiple answers' do
        within '.search-condition-form' do
          all('label.checkbox').first.click
          all('label.checkbox').last.click
          click_on 'Save'
        end
        expect(page).to have_current_path(path)
        expect(page).to have_content(@question.text)
        expect(page).to have_content(@operator_options.first)
        @question.answers.each_with_index do |answer, i|
          if i == 1
            expect(page).not_to have_content(answer.text)
          else
            expect(page).to have_content(answer.text)
          end
        end
      end
    end
  end

  describe 'editing a condition' do
    it 'allows to update condition question' do
      pending 'TODO'
      fail
    end

    it 'allows to update condition operator' do
      pending 'TODO'
      fail
    end

    it 'allows to update condition answer' do
      pending 'TODO'
      fail
    end
  end

  it 'allows to delete a condition' do
    pending 'TODO'
    fail
  end

  it 'allows to delete a condition group' do
    pending 'TODO'
    fail
  end

  describe 'adding a group of conditions' do
    it 'allows to add a condition group' do
      visit path
      expect(page).to have_link('Add group of conditions', href: admin_search_condition_groups_path(search_condition_group: { search_condition_group_id: search.search_condition_group.id}))
      click_on('Add group of conditions')

      expect(page).to have_current_path(path)
      within all('#search .search-condition-group-container').first do
        expect(page).to have_selector('.search-condition-group-container')
        within ('.search-condition-group-container') do
          last_search_condition_group = search.search_condition_group.search_condition_groups.last
          expect(page).to have_link('Add condition', href: new_admin_search_condition_path(search_condition_group_id: last_search_condition_group.id))
          expect(page).to have_link('Add group of conditions', href: admin_search_condition_groups_path(search_condition_group: { search_condition_group_id: last_search_condition_group.id}))
          expect(page).to have_button('Delete group')
        end
      end
    end

    it 'restricts nesting of condition groups to 3', js: true do
      visit path
      click_on('Add group of conditions')
      expect(page).to have_current_path(path)

      within all('#search .search-condition-group-container .search-condition-group-container').first do
        click_on('Add group of conditions')
        expect(page).to have_current_path(path)
      end

      within '#search .search-condition-group-container .search-condition-group-container .search-condition-group-container' do
        last_search_condition_group = search.search_condition_group.search_condition_groups.last.search_condition_groups.last
        expect(page).to have_link('Add condition', href: new_admin_search_condition_path(search_condition_group_id: last_search_condition_group.id))
        expect(page).not_to have_link('Add group of conditions', href: admin_search_condition_groups_path(search_condition_group: { search_condition_group_id: last_search_condition_group.id}))
        expect(page).to have_button('Delete group')
      end
    end
  end
end

RSpec.shared_examples 'shared examples for unreleased requests' do
  describe 'renaming request' do
    it 'provides client-side validation', js: true do
      visit path
      click_on('Rename')
      within 'div#search_name' do
        expect(page).to have_field('search_name')
        fill_in('search_name', with: '')
        click_on('Continue')
        expect(find("label[for='search_name']")).to have_content('This field is required')
      end
    end

    it 'allows to change search name', js: true do
      visit path
      click_on('Rename')
      expect(page).to have_selector('div#search_name')
      within 'div#search_name' do
        fill_in('search_name', with: 'New beautiful name')
        click_on('Continue')
      end
      expect(page).to have_current_path(path)
      expect(page).to have_content("Name: New beautiful name")
    end
  end

  describe 'changing study' do
    let(:inactive_studies) {
      (0..3).each{ FactoryBot.create(:study) }
      Study.inactive
    }
    let(:active_studies) {
      (0..3).each{ FactoryBot.create(:study, state: 'active') }
      Study.active
    }
    let(:options) {
      active_studies.map{|s| "#{s.display_name} - #{s.irb_number}"}
    }
    it 'displays list of available studies', js: true do
      search
      options

      visit path
      click_on('Change study')

      if @user.admin?
        within 'div#search_name' do
          expect(page).to have_select('search_study_id', options: options)
        end
      end

      if @user.researcher?
        expect(page).not_to have_select('search_study_id', options: options)
        @user.studies = active_studies

        visit path
        click_on('Change study')
        expect(page).to have_select('search_study_id', options: options)
      end
    end

    it 'allows to change request study', js: true do
      search
      options

      @user.studies = active_studies if @user.researcher?
      visit path
      click_on('Change study')
      select(options.last, from: 'search_study_id')
      click_on 'Continue'
      expect(page).to have_content("Study: #{active_studies.last.display_name}")
    end
  end

  describe 'deleting request' do
    it 'allows to delere a request', js: true do
      visit path
      accept_confirm do
        find('.search-controls').click_link('Delete')
      end
      expect(page).to have_current_path(admin_searches_path)
      expect(page).not_to have_content(search.display_name)
    end
  end

  include_examples 'shared examples for comments'
  include_examples 'shared examples for copying a request'
  include_examples 'shared examples for search conditions'
end

RSpec.shared_examples 'shared examples for displaying requests' do
  describe 'displaying results', js: true do
    before :each do
      set_results
    end

    it 'displays a list of participants', js: true do
      visit path
      expect(page).to have_content(@participant1.first_name)
      expect(page).to have_content(@participant1.last_name)
      expect(page).to have_content(@studies.first.name)

      expect(page).not_to have_content(@participant2.first_name)
      expect(page).not_to have_content(@participant2.last_name)
    end

    it 'indicates participants with Tier 2 data', js: true do
      visit path
      within '#search_result_list' do
        expect(page).not_to have_selector('.user-circle')
      end

      @survey.tier_2 = true
      @survey.save!

      visit path
      within '#search_result_list' do
        expect(page).to have_selector('.user-circle')
        expect(page).to have_content('Show')

        all('a.dashed_underline').first.click
        expect(page).to have_selector('.modal')
        within('.modal') do
          expect(page).to have_content("#{@participant1.name} Tier 2 surveys")
          expect(page).to have_content(@survey.title)
        end
      end
    end

    describe 'releasing participants', js: true do
      it 'disables release unless participants are selected' do
        visit path
        expect(page).to have_button('Release 0 participants', disabled: true)
      end

      it 'counts selected participants from pages hidden from the view' do
        visit path
        within all('#search_result_list tbody tr').first do
          find('#_participant_ids_').click()
        end
        expect(page).to have_button('Release 1 participant', disabled: false)
        within ('#search_result_list_paginate') do
          click_on '2'
        end
        within all('#search_result_list tbody tr').first do
          find('#_participant_ids_').click()
        end
        expect(page).to have_button('Release 2 participants', disabled: false)
        within ('#search_result_list_paginate') do
          click_on '1'
        end
        expect(page).to have_button('Release 2 participants', disabled: false)
        accept_confirm do
          click_on('Release 2 participants')
        end
        expect(page).to have_current_path(path)
        expect(page).to have_content('2 released / 41 participants returned')
      end

      it 'allows to release selected participants' do
        visit path
        within all('#search_result_list tbody tr').first do
          find('#_participant_ids_').click()
        end
        expect(page).to have_button('Release 1 participant', disabled: false)
        accept_confirm do
          click_on('Release 1 participant')
        end
        expect(page).to have_current_path(path)
        expect(page).to have_content('1 released / 41 participants returned')
      end
    end
  end
end