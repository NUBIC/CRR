# == Schema Information
#
# Table name: answers
#
#  id            :integer          not null, primary key
#  question_id   :integer
#  text          :text
#  help_text     :text
#  display_order :integer
#  code          :string(255)
#  weight        :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Answer < ActiveRecord::Base
  belongs_to :question
  has_many :responses

  # Scopes
  default_scope {order("display_order ASC")}

  validate :proper_question_type
  validates_presence_of :text,:code
  validates_uniqueness_of :display_order, :scope => :question_id
  validates_uniqueness_of :text, :scope => :question_id
  validates_uniqueness_of :code, :scope => :question_id


  after_initialize :default_args

  private

  def default_args
    self.display_order ||= self.question.answers.size
    self.code ||= "a_#{display_order}"
  end
  def check_display_order
    if self.display_order_changed? and question.answers.where(:display_order=>self.display_order).exists? 
        a = question.answers.find_by_display_order(self.display_order)
        a.display_order=self.display_order+1
        a.save
    end
  end
  def proper_question_type
    errors.add(:question,"doesn't support answers") unless question.multiple_choice?
  end
end

