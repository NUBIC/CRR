class Study < ApplicationRecord
  # Dependencies
  include WithActiveState

  # Associations
  has_many :study_involvements, -> { order('end_date DESC, start_date DESC') }, dependent: :restrict_with_error
  has_many :participants, through: :study_involvements
  has_many :user_studies
  has_many :users, through: :user_studies
  has_many :searches

  # Validations
  validates :state, inclusion: { in: STATES }, presence: true
  validates_presence_of :irb_number, :name

  # Hooks
  after_initialize :default_args

  # Scopes
  scope :search, -> (param){ where("irb_number ilike ? or name ilike ? ","%#{param}%","%#{param}%") }

  def active_participants
    study_involvements.active.collect{|s| s.participant}.flatten.uniq
  end

  def search_display
    "#{id} - #{name} - #{irb_number}"
  end

  def display_name
    short_title.blank? ? name : short_title
  end

  def user_emails
    users.active.pluck(:email).reject(&:blank?)
  end

  private
    def default_args
      self.deactivate if self.state.blank?
    end
end
