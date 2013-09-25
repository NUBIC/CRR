class Section < ActiveRecord::Base
     
  # Associations
  has_many :questions, :dependent => :destroy
  belongs_to :survey

  # Scopes
  scope :with_includes, { :include => {:questions => [:answers, :question_group, {:dependency => :dependency_conditions}]}}

      # Validations
  validates_presence_of :title, :display_order,:survey,:survey_id


  # Instance Methods

  def initialize(*args)
    super(*args)
    default_args
  end

  def default_args
    self.display_order ||= self.survey.sections.size
  end

  def soft_errors
    full_list = []
    full_list << "sections must have at least one question" if questions.empty?
    questions.each do |q|
      full_list << q.soft_errors 
    end
    return full_list.flatten.uniq.compact
  end
end
