require 'csv'

module CSVExporter
  class ResponseSet
    attr_accessor :response_set, :survey_fields, :section_fields, :question_fields, :answer_fields

    def initialize(options={})
      @response_set  = options[:response_set]
      raise 'ResponseSet needs to be provided' unless response_set.present?
    end

    def participant_fields(record=nil)
      {
        'participant_id'  => ->(record){ record.id if record },
      }
    end

    def survey_fields(record=nil)
      {
        'survey'  => ->(record){ record.title if record }
      }
    end

    def section_fields(record=nil)
      {
        'section_name'  => ->(record){ record.title if record }
      }
    end

    def question_fields(record=nil)
      {
        'question_text'  => ->(record){ record.text if record },
        'question_code'  => ->(record){ record.code if record }
      }
    end

    def answer_fields(record=nil)
      {
        'answer_value' => ->(record){ record.to_s if record },
        'answer_code'  => ->(record){ record && record.is_a?(Answer) ? record.code : nil}
      }
    end

    def keys
      participant_fields.keys + survey_fields.keys + section_fields.keys + question_fields.keys + answer_fields.keys
    end

    def each(&block)
      # how_long = Benchmark.measure do
      # yield CSV::Row.new(keys, keys, true).to_csv
      yield keys

      @response_set.responses.includes(:answer).joins(question: :section).order('sections.display_order').each do |response|
        values =  participant_fields.values.map{|v| v.call(@response_set.participant)} +
                  survey_fields.values.map{|v| v.call(@response_set.survey)} +
                  section_fields.values.map{|v| v.call(response.question.section)} +
                  question_fields.values.map{|v| v.call(response.question)}

        if response.question.multiple_choice?
          values = values + answer_fields.values.map{|v| v.call(response.answer)}
        else
          values = values + answer_fields.values.map{|v| v.call(response)}
        end
        # yield CSV::Row.new( keys, values ).to_csv
        yield values
      end
      # Rails.logger.info "Little my says, it took #{how_long}"
    end
  end
end
