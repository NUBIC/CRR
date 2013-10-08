# == Schema Information
#
# Table name: studies
#
#  id          :integer          not null, primary key
#  irb_number  :string(255)
#  active_on   :date
#  inactive_on :date
#

class Study < ActiveRecord::Base
  has_many :study_involvements
  validates_presence_of :active_on
  validate :inactive_on_cannot_be_before_active_on

  scope :active, where("active_on < '#{Date.today}' and (inactive_on is null or inactive_on > '#{Date.today}')")

  def state
  end

  private
  def date_validity

  end

  def inactive_on_cannot_be_before_active_on
    if inactive_on.present? && inactive_on < active_on
      errors.add(:inactive_on, "can't be before active on")
    end
  end
end
