class Participant < ActiveRecord::Base
  # condensed form of name

  has_many :response_sets
  has_many :contact_logs
  has_many :study_involvements

  validates_presence_of :first_name
  validates_presence_of :last_name
  def name
    "#{self.first_name} #{self.last_name}"
  end

  # condensed form of address
  def address
    "#{self.address_line1} #{self.address_line2} #{self.city},#{self.state} #{self.zip}"
  end

  def on_study?
    study_involvements.where("start_date < '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')").count > 0
  end

end
