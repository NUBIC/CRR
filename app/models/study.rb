# == Schema Information
#
# Table name: studies
#
#  id         :integer          not null, primary key
#  irb_number :string(255)
#  name       :string(255)
#  notes      :text
#  state      :string(255)
#

class Study < ActiveRecord::Base
  has_many :study_involvements,:dependent=>:restrict_with_error
  has_many :participants,:through=>:study_involvements
  has_many :user_studies
  has_many :users, :through=>:user_studies
  validates_presence_of :state,:irb_number,:name
  STATES= ['active','inactive']

  scope :active, where(:state=>:active)
  validates_inclusion_of :state, :in => STATES
  after_initialize :default_args

  scope :search , proc {|param|
    where("irb_number ilike ? or name ilike ? ","%#{param}%","%#{param}%")}

  def active?
    state.eql?('active')
  end

  def active_participants
    study_involvements.active
  end

  def search_display
    "#{id} - #{irb_number} - #{name}"
  end

  private
  def default_args
    self.state ||='inactive'
  end

end
