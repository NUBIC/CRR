class Answer < ActiveRecord::Base
  belongs_to :question
  has_many :responses

  # Scopes
  default_scope {order("display_order ASC")}

  validates_presence_of :text,:code
  validates_uniqueness_of :display_order, :scope => :question_id
  validates_uniqueness_of :text, :scope => :question_id
  validates_uniqueness_of :code, :scope => :question_id
  #before_validation  :check_display_order
    # this causes issues with building and saving


    # Instance Methods
    def initialize(*args)
      super(*args)
      default_args
    end

    def default_args
      self.display_order ||= self.question.answers.size
      self.code ||= "a_#{display_order}"
    end
  private
  def check_display_order
    if self.display_order_changed? and question.answers.where(:display_order=>self.display_order).exists? 
        a = question.answers.find_by_display_order(self.display_order)
        a.display_order=self.display_order+1
        a.save
    end
  end
end

