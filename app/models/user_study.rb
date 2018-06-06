class UserStudy < ApplicationRecord
  belongs_to :user
  belongs_to :study

  validates_presence_of :user, :study
end
