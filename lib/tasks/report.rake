require 'csv'

namespace :export do
  desc "Export response set by code"
  task :export_response_set, [:code] => [:environment] do |t, args|
    code = args[:code]
    raise ArgumentError, "Survey code has to be provided" if code.blank?

    surveys = Survey.where(code: code)
    raise ArgumentError, "Survey with code #{code} could not be found" if surveys.empty?

    surveys.each do |survey|
      file_name = "#{Rails.root}/tmp/export-survey-#{survey.title.parameterize}-#{Date.today.to_s(:db)}.csv"
      CSV.open(file_name, 'w') do |csv|
        questions = Question.where("response_type != 'none'").joins(:section).where(sections: { survey_id: survey.id }).reorder('sections.display_order, questions.display_order')
        csv << ['id', 'participant state'] + questions.map(&:text)
        ResponseSet.joins(:survey).where(survey_id: survey.id).each do |response_set|
          row = [ response_set.participant ? response_set.participant.id : '', response_set.participant ? response_set.participant.stage : '' ]
          questions.each do |question|
            if response_set.respond_to?("q_#{question.id}".to_sym)
              if question.multiple_choice?
                row << Answer.where(id: response_set.send("q_#{question.id}".to_sym)).map(&:text).join('|')
              else
                row << response_set.send("q_#{question.id}".to_sym)
              end
            else
              row << ''
            end
          end
          csv << row
        end
      end
    end
  end
end