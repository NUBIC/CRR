require 'rails_helper'
require 'csv_exporter/participant'

RSpec.describe CSVExporter::Participant do
  before(:each) do
    @participants = []
    (1..10).each do |i|
      @participants << FactoryBot.create(:participant)
    end

    @surveys = []
    (1..5).each do |i|
      survey  = FactoryBot.create(:survey, multiple_section: true, title: Faker::Lorem.sentence)
      section = survey.sections.create(title: Faker::Lorem.sentence)
      Question::VALID_RESPONSE_TYPES.each do |response_type|
        unless response_type == 'none'
          question = section.questions.create(text: Faker::Lorem.sentence, response_type: response_type)
          if response_type == 'pick_many' || response_type == 'pick_one'
            (1..3).each do |j|
              question.answers.create(text: Faker::Lorem.word)
            end
          end
        end
      end
      @surveys << survey
    end
  end

  it 'should throw error if participants are not provided' do
    expect{CSVExporter::Participant.new()}.to raise_error('Participants need to be provided')
  end

  it 'should throw error if participant export parameters are not provided' do
    expect{CSVExporter::Participant.new(participants: Participant.all)}.to raise_error('At least one participant export field needs to be selected')
  end

  it 'should throw error if participant export parameter is not configured' do
    participant_export_params = {}
    ['id', 'address', 'favorite food'].map{|p| participant_export_params[p] = p}
    expect{CSVExporter::Participant.new(
      participants:               Participant.all,
      participant_export_params:  participant_export_params
    )}.to raise_error("Unknown participant export field(s): address, favorite food")
  end

  it 'should set participant fields' do
    exporter = CSVExporter::Participant.new(
      participants:               Participant.all,
      participant_export_params:  {'id' => 'id'}
    )
    expect(exporter.participant_fields).not_to be_empty
    expect(exporter.participant_fields.keys).to include('id')
    expect(exporter.participant_fields.keys).to include('first_name')
    expect(exporter.participant_fields.keys).to include('last_name')
    expect(exporter.participant_fields.keys).to include('studies')
    expect(exporter.participant_fields.keys).to include('join_date')
    expect(exporter.participant_fields.keys).to include('account_email')
    expect(exporter.participant_fields.keys).to include('tier_2')
    expect(exporter.participant_fields.keys).to include('contact_information')
    expect(exporter.participant_fields.keys).to include('source')
    expect(exporter.participant_fields.keys).to include('relationships')
  end

  describe 'setting up selected questions' do
    it 'sets up selected questions if provided with question ids' do
      questions = @surveys.map{|s| s.questions.sample(2)}.flatten
      exporter = CSVExporter::Participant.new(
        participants:               Participant.all,
        participant_export_params:  {'id' => 'id'},
        question_export_params:     { id: questions.map(&:id)}
      )
      expect(exporter.selected_questions).to match_array(questions)
    end

    it 'sets up selected questions if provides with section ids' do
      sections = @surveys.map{|s| s.sections.sample}.flatten
      exporter = CSVExporter::Participant.new(
        participants:               Participant.all,
        participant_export_params:  {'id' => 'id'},
        section_export_params:      { id: sections.map(&:id)}
      )
      expect(exporter.selected_questions).to match_array(sections.map(&:questions).flatten)
    end

    it 'sets up selected questions if provides with survey ids' do
      surveys = @surveys.sample(2)
      exporter = CSVExporter::Participant.new(
        participants:               Participant.all,
        participant_export_params:  {'id' => 'id'},
        survey_export_params:       { id: surveys.map(&:id)}
      )
      expect(exporter.selected_questions).to match_array(surveys.map(&:questions).map(&:to_a).flatten)
    end
  end

  it 'should set survey fields' do
    questions = @surveys.map{|s| s.questions.sample(2)}.flatten
    exporter = CSVExporter::Participant.new(
      participants:               Participant.all,
      participant_export_params:  {'id' => 'id'},
      question_export_params:     { id: questions.map(&:id)}
    )
    questions.each do |question|
      expect(exporter.survey_fields).to include
      {
        question.id => {
          label: "#{question.section.survey.title}:#{question.section.title}:#{question.text}",
          method: ->(record){ record.send("q_#{question.id}_string".to_sym) if record }
        }
      }
    end
  end

  describe 'generating CSV' do
    before(:each) do
      surveys               = @surveys.sample(3)
      @tier_2_survey        = surveys.first
      @tier_2_survey.tier_2 = true
      @tier_2_survey.save!
      @export_questions          = surveys.map{|s| s.questions.sample(3)}.flatten
      @export_participant_fields = {}
      [
        'id', 'first_name', 'last_name', 'studies', 'join_date', 'account_email',
        'tier_2', 'contact_information', 'source', 'relationships'
      ].map{|p| @export_participant_fields[p] = p}

      Participant.all.sample(5).each do |participant|
        surveys.each do |survey|
          response_set = participant.response_sets.create(survey_id: survey.id)
          survey.questions.each do |question|
            if question.response_type == 'pick_many'
              response_set.update_attributes("q_#{question.id}".to_sym => question.answers.sample(2).map(&:id).map(&:to_s))
            elsif question.response_type == 'pick_one'
              response_set.update_attributes("q_#{question.id}".to_sym => question.answers.sample(1).map(&:id).map(&:to_s).first)
            elsif question.response_type == 'date'
              response_set.update_attributes("q_#{question.id}".to_sym => Date.today)
            elsif question.response_type == 'short_text' || question.response_type == 'long_text'
              response_set.update_attributes("q_#{question.id}".to_sym => Faker::Company.name )
            end
            # TODO: test file upload
          end
        end
      end

      (1..5).each do |i|
        FactoryBot.create(:study)
      end

      Participant.all.sample(4).each do |participant|
        Study.all.sample(2).each do |study|
          FactoryBot.create(:study_involvement, participant: participant, study: study)
        end
      end

      Participant.all.sample(5).each do |participant|
        participant.account = FactoryBot.create(:account)
        participant.save!
      end

      @exporter = CSVExporter::Participant.new(
        participants:               Participant.all,
        participant_export_params:  @export_participant_fields,
        question_export_params:     { id: @export_questions.map(&:id)}
      )
    end

    it 'should return CSV headers' do
      i = 0
      @exporter.each do |record|
        if i == 0
          expect(record).not_to be_blank
          expect(CSV.parse_line(record)).to include(*@exporter.participant_fields.values.map{|v| v[:label]})
          expect(CSV.parse_line(record)).to include(*@exporter.survey_fields.values.map{|v| v[:label]})
        end
        i = i+1
      end
    end

    it 'should return a CSV row for each participant' do
      records = ''
      @exporter.each do |record|
        records << record
      end
      csv = CSV.parse(records, headers: true)
      Participant.all.each do |participant|
        participant_rows = csv.select{|row| row['First Name'] == participant.first_name && row['Last Name'] == participant.last_name}
        expect(participant_rows).not_to be_empty
        expect(participant_rows.length).to eq 1

        participant_row = participant_rows.first
        expect(participant_row['First Name']).to  eq participant.first_name
        expect(participant_row['Last Name']).to   eq participant.last_name
        if participant.studies.any?
          expect(participant_row['Studies']).to eq participant.studies.map(&:irb_number).join('|')
        else
          expect(participant_row['Studies']).to be_blank
        end
        expect(participant_row['Join Date']).to eq participant.created_at.strftime('%m/%d/%Y').to_s
        if participant.account.present?
          expect(participant_row['Account Email']).to eq participant.account.email
        else
          expect(participant_row['Account Email']).to be_blank
        end
        if participant.tier_2_surveys.any?
          expect(participant_row['Tier 2']).to eq 'yes'
        else
          expect(participant_row['Tier 2']).to eq 'no'
        end
        expect(participant_row['Contact I formations']).to  eq participant.address
        expect(participant_row['Source']).to                eq participant.hear_about_registry
        expect(participant_row['Relationships']).to         eq participant.relationships_string


        @export_questions.each do |export_question|
          response_set =  participant.response_sets.detect{|rs| rs.responses.detect{|r| r.question_id == export_question.id}}
          column_name  = "#{export_question.section.survey.title}: #{export_question.section.title}: #{export_question.text}"
          if response_set
            expect(participant_row[column_name]).to eq response_set.send("q_#{export_question.id}_string")
          else
            expect(participant_row[column_name]).to be_blank
          end
        end
      end
    end
  end
end
