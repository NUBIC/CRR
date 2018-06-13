require 'csv'

module CSVExporter
  class Participant
    attr_accessor :participants, :participant_selected_fields,
                  :question_export_params, :section_export_params,
                  :survey_export_params, :selected_questions, :selected_surveys,
                  :participant_fields, :survey_fields

    def initialize(options={})
      raise 'Participants need to be provided' unless options[:participants].present?
      @participants                 = options[:participants]
      @participant_selected_fields  = options[:participant_export_params]
      @question_export_params       = options[:question_export_params]
      @section_export_params        = options[:section_export_params]
      @survey_export_params         = options[:survey_export_params]
      @selected_questions           = get_selected_questions
      @selected_surveys             = get_selected_surveys
      @participant_fields           = get_participant_fields
      @survey_fields                = get_survey_fields
    end

    def get_selected_questions
      all_questions = Question.real.includes(section: :survey)
      questions_by_survey  = all_questions.where(sections: { survey_id: survey_export_params[:id]})
      questions_by_section = all_questions.where(section_id: section_export_params[:id])
      questions_by_id      = all_questions.where(id: question_export_params[:id])
      questions_by_survey.or(questions_by_section).or(questions_by_id).reorder('surveys.state ASC', 'surveys.created_at DESC', 'sections.display_order', 'questions.display_order')
    end

    def get_selected_surveys
      all_surveys   = Survey.includes(sections: :questions)
      surveys_by_id       = all_surveys.where(id: survey_export_params.to_h[:id])
      surveys_by_section  = all_surveys.where(sections: { section_id: section_export_params.to_h[:id] })
      surveys_by_question = all_surveys.where(sections: { questions: { question_id: section_export_params.to_h[:id] }})
      surveys_by_id.or(surveys_by_section).or(surveys_by_question)
    end

    def get_participant_fields(record = nil)
      {
        'id'  => {
          label:  'Participant ID',
          method: ->(record){ record.id },
        },
        'first_name'  => {
          label:  'First Name',
          method: ->(record){ record.first_name },
        },
        'last_name' => {
          label:  'Last Name',
          method: ->(record){ record.last_name },
        },
        'studies' => {
          label:  'Studies',
          method: ->(record){ "#{record.studies.map(&:irb_number).join('|')}" if record.studies.any? },
        },
        'join_date' => {
          label:  'Join Date',
          method: ->(record){ record.created_at.strftime('%m/%d/%Y').to_s },
        },
        'account_email' => {
          label:  'Account Email',
          method: ->(record){ record.account.email if record.account.present?},
        },
        'tier_2' => {
          label:  'Tier 2',
          method: ->(record){ record.tier_2_surveys.any? ? 'yes' : 'no' },
        },
        'contact_information' => {
          label:  'Contact I formations',
          method: ->(record){ record.address },
        },
        'source' => {
          label:  'Source',
          method: ->(record){ record.hear_about_registry },
        },
        'relationships' => {
          label:  'Relationships',
          method: ->(record){ record.relationships_string },
        }
      }
    end

    def get_survey_fields(record = nil)
      fields_hash = {}
      @selected_questions.pluck('surveys.title', 'sections.title', 'questions.text', 'questions.id').map do |q|
        q_id = q.pop
        fields_hash[q_id] = { label: q.join(':'), method: ->(record){ record.send("q_#{q_id}_string".to_sym) if record }}
      end
      fields_hash
    end

    def each(&block)
      how_long = Benchmark.measure do
        headers = participant_headers + survey_headers
        yield CSV.generate_line(headers)

        @participants.includes(:studies, :account, response_sets: [survey: { sections: :questions }, responses: [:question, :answer]]).find_in_batches do |group|
          group.each do |participant|
            data = participant_data(participant)
            data.push(*survey_data(participant)) if @selected_surveys
            yield CSV.generate_line(data)
          end
        end
      end
      Rails.logger.info "Little my says, it took #{how_long}"
    end

    def participant_headers
      participant_fields.select{|k,v| participant_selected_fields.has_key?(k)}.map{|k,v| v[:label]}
    end

    def survey_headers
      survey_fields.map{|k,v| v[:label]}
    end

    def participant_data(participant)
      participant_fields.select{|k,v| participant_selected_fields.has_key?(k)}.map{|k, v| v[:method].call(participant)}
    end

    def survey_data(participant)
      data = []
      survey_fields.each do |k, v|
        response_sets =  participant.response_sets.select{|rs| rs.responses.detect{|r| r.question_id == k}}
        if response_sets.any?
          data << response_sets.map{|rs| v[:method].call(rs)}.reject(&:blank?).compact.join("; ")
        else
          data << ''
        end
      end
      data
    end
  end
end
