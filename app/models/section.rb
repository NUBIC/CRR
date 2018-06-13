class Section < ApplicationRecord
  # Associations
  has_many :questions, dependent: :destroy
  belongs_to :survey

  # Validations
  validates_presence_of :title, :display_order,:survey
  validates_uniqueness_of :survey_id, unless:  Proc.new { |s| s.survey.multiple_section? }

  # Scopes
  scope :with_includes, -> { includes(questions: [:answers, :question_group, { dependency: :dependency_conditions}])}
  default_scope { order('display_order ASC') }

  # Hooks
  after_initialize :default_args
  before_validation :remove_trailing_spaces

  def default_args
    self.display_order ||= survey.sections.size + 1
  end

  def soft_errors
    full_list = []
    full_list << 'sections must have at least one question' if questions.empty?
    questions.each do |q|
      full_list << q.soft_errors
    end
    return full_list.flatten.uniq.compact
  end

  # methods to allow for custom JSON generation
  def node_type
    self.class.name.parameterize
  end

  def node_text
    self.title
  end

  def node_unique_id
    "#{self.node_type}_#{self.id}".parameterize
  end

  def has_children
    true
  end

  def node_parent
    "#{self.survey.class.name}_#{self.survey.id}".parameterize
  end

  private
    def remove_trailing_spaces
      self.title = self.title.strip if self.title.present?
    end
end
