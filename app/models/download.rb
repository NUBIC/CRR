class Download < ActiveRecord::Base
  mount_uploader :consent, Tier2ConsentUploader

  # Associations
  belongs_to :user
  belongs_to :study_involvement

  # Validations
  validates_presence_of :consent, :user, :study_involvement

  # Hooks
  after_initialize :set_default_args

  def set_default_args
    self.date ||= Time.now
  end
end
