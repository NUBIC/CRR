# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  survey_id     :integer
#  section_id    :integer
#  text          :text
#  code          :string(255)
#  is_mandatory  :boolean
#  response_type :string(255)
#  display_order :integer
#  help_text     :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Question < ActiveRecord::Base


  belongs_to :survey
  belongs_to :section
  belongs_to :question_group, :dependent => :destroy
  has_many   :answers, :dependent => :destroy

  #listed of types supported by data capture none caters to labels 
  #VALID_RESPONSE_TYPES=["single_choice","multiple_choice","number","text","date","none"].freeze
  VALID_RESPONSE_TYPES={"single_choice"=>'select',"multiple_choice"=>"check_box","number"=>"float","short_text"=>"string","long_text"=>"text","date"=>"string","none"=>"none"}.freeze

  default_scope {order("display_order ASC")}
  
  validates_presence_of :text, :display_order,:response_type,:section_id,:section
  validates_inclusion_of :is_mandatory, :in => [true, false]
  validates_inclusion_of :response_type, :in => VALID_RESPONSE_TYPES.keys

  validates_uniqueness_of :display_order,:scope=>:section_id
  validates_uniqueness_of :reference,:scope=>:section_id

  before_validation  :check_display_order

  validate :validate_question_type
  


      # Instance Methods
  def initialize(*args)
    super(*args)
    default_args
  end


  def soft_errors
    if ["single_choice","multiple_choice"].include?(response_type)
      return "multiple choice questions must have at least 2 answers" if answers.size < 2
    end
  end


  def date?
    response_type.eql?('date')
  end
  def long_text?
    response_type.eql?('long_text')
  end
  def short_text?
    response_type.eql?('short_text')
  end
  def number?
    response_type.eql?('number')
  end


  private
  def default_args
    self.display_order ||= self.section.questions.size
    self.reference ||= "q_#{display_order}"
  end

  def check_display_order
    if self.display_order_changed? and section.questions.where(:display_order=>self.display_order).exists? 
        q = section.questions.find_by_display_order(self.display_order)
        q.display_order=self.display_order+1
        q.save
    end
  end

  def validate_question_type
    unless ["single_choice","multiple_choice"].include?(response_type)
      errors.add(:question_type,"does not support having answers") unless answers.empty?
    end
  end

end

