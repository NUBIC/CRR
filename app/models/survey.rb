require 'csv'
class Survey < ActiveRecord::Base
  has_many :response_sets,:dependent=>:destroy
  #has_many :questions,:dependent=>:destroy
  has_many :sections, :dependent=>:destroy


  #attr_accessible :score_configurations_attributes, :access_code, :active_at, :inactive_at, :study_id, :irb_number, :is_public, :title,:custom_numbering
 # scope :active, where("active_at < '#{Time.now}' and (inactive_at is null or inactive_at > '#{Time.now}')")



  validates_presence_of :title,:state#,:description

  validate :activation_check

  def questions
    Question.where("section_id in (?)",sections.collect{|s| s.id})
  end

  def initialize(*args)
    super(*args)
    default_args
  end

  def default_args
    self.state ||= "inactive"
  end

  def self.export(params)
    {:report => "", :name => "blank"} if params[:scores].blank? && params[:responses].blank?

    # surveys
    scores_surveys = Survey.find(params[:scores] || [])
    responses_surveys = Survey.includes({:sections => {:questions => :answers}}).find(params[:responses] || [])
    questions = responses_surveys.map(&:sections).flatten.map(&:questions).flatten.reject{|q| q.display_type == "label"}
    answers = questions.map(&:answers).flatten
    score_configurations = scores_surveys.map(&:score_configurations).flatten

    # response sets
    response_sets = ResponseSet.includes(:involvement,{:responses => [:question, :answer]}).where(:survey_id => (responses_surveys + scores_surveys)).sort_by(&:created_at)

    # data for responses
    data_method = case params[:data]
      when "answer_reference_identifier"
        lambda {|responses| responses.map{|r| r.answer.response_class == "answer" ? r.answer.reference_identifier : [r.answer.reference_identifier, r.json_value].compact.join(": ")}.compact.join(", ") }
      when "answer_weight"
        lambda {|responses| responses.map{|r| r.answer.response_class == "answer" ? r.answer.weight : [r.answer.weight, r.json_value].compact.join(": ")}.compact.join(", ") }
      when "response_count"
        lambda {|responses| responses.count }
      else # :answer_text is default
        lambda {|responses| responses.map{|r| r.answer.response_class == "answer" ? r.answer.text : [r.answer.text, r.json_value].compact.join(": ")}.compact.join(", ") }
    end


    id_columns = ["first_name", "last_name", "case_number", "nmh_mrn", "ric_mrn", "nmff_mrn", "effective_date"]
    score_columns = score_configurations.map{|sc| "#{sc.survey.title}: #{sc.name}"}

    csv_string = CSV.generate do |csv|
      if responses_surveys.blank? or questions.blank?
        csv << ["Note: "] + id_columns + score_columns
      elsif params[:column] == "question"
        csv << ["Note: this sheet contains 3 different header rows. You may delete the header rows you do not need as well as this first column."]
        csv << ["question.reference_identifier"] +   id_columns + score_columns + questions.map(&:reference_identifier)
        csv << ["question.data_export_identifier"] + id_columns + score_columns + questions.map(&:data_export_identifier)
        csv << ["question.text"] +                   id_columns + score_columns + questions.map(&:text)
      else # params[:column] == "answer" is default
        csv << ["Note: this sheet contains 7 different header rows. You may delete the header rows you do not need as well as this first column."]
        csv << ["question.reference_identifier"] +   id_columns + score_columns + questions.map{|q| q.answers.count.times.map{|i| q.reference_identifier} }.flatten
        csv << ["question.data_export_identifier"] + id_columns + score_columns + questions.map{|q| q.answers.count.times.map{|i| q.data_export_identifier} }.flatten
        csv << ["question.text"] +                   id_columns + score_columns + questions.map{|q| q.answers.count.times.map{|i| q.text} }.flatten
        csv << ["answer.weight"] +                   id_columns + score_columns + answers.map(&:weight)
        csv << ["answer.reference_identifier"] +     id_columns + score_columns + answers.map(&:reference_identifier)
        csv << ["answer.data_export_identifier"] +   id_columns + score_columns + answers.map(&:data_export_identifier)
        csv << ["answer.text"] +                     id_columns + score_columns + answers.map(&:text)
      end
      if params[:row] == "person"
        response_sets.group_by(&:involvement).each do |involvement, rs|
          csv << [""] + ["first_name", "last_name", "case_number", "nmh_mrn", "ric_mrn", "nmff_mrn"].map{|a| involvement.send(a)} + [rs.map(&:effective_date).compact.join("; ")] +
                  score_configurations.map{|sc| rs.map(&:scores).flatten.select{|score| score.score_configuration_id == sc.id }.map(&:value).join(";") } +
                  if params[:column] == "question"
                    questions.map{|q| rs.map{|s| data_method.call(s.responses.select{|r| r.question_id == q.id}) }.reject(&:blank?).compact.join("; ")}
                  else
                    answers.map{|a| rs.map{|s| data_method.call(s.responses.select{|r| r.answer_id == a.id}) }.reject(&:blank?).compact.join("; ")}
                  end
        end
      elsif params[:row] == "response_set"
        response_sets.each do |rs|
          csv << [""] + ["first_name", "last_name", "case_number", "nmh_mrn", "ric_mrn", "nmff_mrn"].map{|a| rs.involvement.send(a)} + [rs.effective_date.to_s] +
                  score_configurations.map{|sc| rs.scores.select{|score| score.score_configuration_id == sc.id }.map(&:value).join(",") } +
                  if params[:column] == "question"
                    questions.map{|q| data_method.call(rs.responses.select{|r| r.question_id == q.id}) }
                  else
                    answers.map{|a| data_method.call(rs.responses.select{|r| r.answer_id == a.id}) }
                  end
        end
      end
    end
    {:report => csv_string, :name => "#{'scores_' if !scores_surveys.empty?}#{'responses_' if !responses_surveys.empty?}#{Time.now.strftime("%Y-%m-%d_%H-%M")}"}
  end


  def active?
    self.state.eql?("active")
  end

  #this method checks that the survey is in fact valid for activation
  #checks things like it has at least one section, at least one question etc
  def soft_errors
    activation_errors = []
    if sections.size < 1
      activation_errors << "must have at least one section" 
    else
      sections.each do |section|
        activation_errors << section.soft_errors 
      end
    end
    return activation_errors.flatten.uniq.compact
  end

  def activation_check
    if active?
      errors.add(:survey,soft_errors.to_sentence) unless soft_errors.empty?
    end
  end

end

