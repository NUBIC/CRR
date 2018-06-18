class ConsentSignature < ApplicationRecord
  # Associations
  belongs_to :consent
  belongs_to :participant

  # Validations
  validates_presence_of :date, :participant, :consent

  # Hooks
  after_initialize :default_args

  private
    def default_args
      self.date ||= Date.today
    end
end
