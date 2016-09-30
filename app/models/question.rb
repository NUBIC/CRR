class Question < ActiveRecord::Base
  # Globals
  VALID_RESPONSE_TYPES            = ['pick_one', 'pick_many', 'number', 'short_text', 'long_text', 'date', 'none', 'birth_date'].freeze
  FORM_RESPONSE_TYPE_TRANSLATION  = {
    'pick_one'    => 'select',
    'pick_many'   => 'check_box',
    'number'      => 'float',
    'short_text'  => 'string',
    'long_text'   => 'text',
    'date'        => 'string',
    'none'        => 'none',
    'birth_date'  => 'string'
  }.freeze

  VIEW_RESPONSE_TYPE_TRANSLATION  = {
    'pick_one'    => 'Multiple Choice - Pick One',
    'pick_many'   => 'Multiple Choice - Pick Many',
    'number'      => 'Number',
    'short_text'  => 'Short Text',
    'long_text'   => 'Long Text',
    'date'        => 'Date',
    'birth_date'  => 'Birth Date',
    'none'        => 'Instruction (no response)'
  }.freeze

  # Associations
  belongs_to :section
  has_many   :answers, dependent: :destroy

  # Validations
  validates_presence_of     :text, :display_order, :response_type, :code, :section
  validates_inclusion_of    :is_mandatory, in: [true, false], allow_blank: true
  validates_inclusion_of    :response_type, in: VALID_RESPONSE_TYPES
  validates_uniqueness_of   :display_order, scope: :section_id
  validates_uniqueness_of   :code, scope: :section_id
  validate :validate_question_type, :code_unique

  # Hooks
  before_validation :check_display_order, :remove_trailing_spaces
  after_initialize  :default_args

  # Scopes
  default_scope {order('display_order ASC')}

  def self.search(param)
    unscoped.joins(section: :survey).where('text ilike ? ', "%#{param}%").where("response_type != 'none'").order('surveys.title, questions.display_order')
  end

  def soft_errors
    if multiple_choice?
      return 'multiple choice questions must have at least 2 answers' if answers.size < 2
    end
  end

  def multiple_choice?
    pick_one? || pick_many?
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

  def birth_date?
    response_type.eql?('birth_date')
  end

  def true_date?
    date? || birth_date?
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
    "#{section.survey.title} - #{section.title} - #{text}"
  end

  def survey_title
    section.survey.title
  end

  private
    def default_args
      if self.section
        self.display_order = self.section.questions.size + 1 if self.display_order.blank?
        self.code = "q_#{self.section.survey.questions.size + 1}" if self.code.blank?
      end
    end

    def check_display_order
      if self.display_order_changed? && self.section && self.section.questions.where(display_order: self.display_order).exists?
          q = section.questions.find_by_display_order(self.display_order)
          q.display_order = self.display_order + 1
          q.save
      end
    end

    def validate_question_type
      unless multiple_choice?
        errors.add(:type, 'does not support having answers') unless answers.empty?
      end
    end

    def code_unique
      if self.section.present?
        self.section.survey.questions.each do |question|
          errors.add(:code, 'already taken') if !question.eql?(self) && question.code.eql?(self.code)
        end
      end
    end

    def remove_trailing_spaces
      self.text = self.text.strip if self.text.present?
    end
end

