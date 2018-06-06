class Comment < ApplicationRecord
  # Associations
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # Validations
  validates_presence_of :content

  # Hooks
  after_initialize :set_default_args

  def set_default_args
    self.date ||= Time.now
  end
end
