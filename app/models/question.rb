# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
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

  belongs_to :section
  has_many   :answers, :dependent => :destroy

  #listed of types supported by data capture none caters to labels 
  #VALID_RESPONSE_TYPES=["single_choice","multiple_choice","number","text","date","none"].freeze
  VALID_RESPONSE_TYPES=["pick_one","pick_many","number","short_text","long_text","date","none"].freeze
  FORM_RESPONSE_TYPE_TRANSLATION={"pick_one"=>'select',"pick_many"=>"check_box","number"=>"float","short_text"=>"string","long_text"=>"text","date"=>"string","none"=>"none"}.freeze

  VIEW_RESPONSE_TYPE_TRANSLATION={"pick_one"=>'Multiple Choice - Pick One',"pick_many"=>"Multiple Choice - Pick Many","number"=>"Number","short_text"=>"Short Text","long_text"=>"Long Text","date"=>"Date","none"=>"Instruction (no response)"}.freeze

  default_scope {order("display_order ASC")}
  
  # Scopes
  #attr_accessible :score_code

  validates_presence_of :text, :display_order,:response_type,:code,:section
  validates_inclusion_of :is_mandatory, :in => [true, false],:allow_blank=>true
  validates_inclusion_of :response_type, :in => VALID_RESPONSE_TYPES

  validates_uniqueness_of :display_order,:scope=>:section_id
  validates_uniqueness_of :code,:scope=>:section_id

  before_validation  :check_display_order

  validate :validate_question_type,:code_unique 
  
        # Whitelisting attributes

  after_initialize :default_args

  #validates :code, :format => { :with => /^[a-zA-Z0-9_]*$/, :message => "Only letters numbers and underscores - no spaces" }
  scope :search , proc {|param|
    where("text ilike ? ","%#{param}%")}

  def soft_errors
    if ["pick_one","pick_many"].include?(response_type)
      return "multiple choice questions must have at least 2 answers" if answers.size < 2
    end
  end

  def multiple_choice?
    ["pick_one","pick_many"].include?(response_type)
  end

  def pick_many?
    response_type.eql?('pick_many')
  end
  def pick_one?
    response_type.eql?('pick_one')
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
  def label?
    response_type.eql?('none')
  end


  def search_display
    "#{section.survey.title} - #{text}"
  end


  private
  def default_args
    self.display_order= self.section.questions.size+1 if self.display_order.blank?
    self.code = "q_#{self.section.survey.questions.size+1}" if self.code.blank?
  end

  def check_display_order
    if self.display_order_changed? and section.questions.where(:display_order=>self.display_order).exists? 
        q = section.questions.find_by_display_order(self.display_order)
        q.display_order=self.display_order+1
        q.save
    end
  end

  def validate_question_type
    unless ["pick_one","pick_many"].include?(response_type)
      errors.add(:type,"does not support having answers") unless answers.empty?
    end
  end
  def code_unique
    self.section.survey.questions.each do |question|
      errors.add(:code,"already taken") if !question.eql?(self) and question.code.eql?(self.code) 
    end
  end
end

