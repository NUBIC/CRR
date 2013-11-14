# == Schema Information
#
# Table name: consents
#
#  id           :integer          not null, primary key
#  content      :text
#  state        :string(255)
#  accept_text  :string(255)      default("I Accept")
#  decline_text :string(255)      default("I Decline")
#  consent_type :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Consent < ActiveRecord::Base
  has_many :consent_signatures,:dependent=>:restrict

  TYPES = ['Adult','Child']
  STATES= ['active','inactive']

  validates_inclusion_of :state, :in => STATES
  after_initialize :default_args



  def self.active_consent
    Consent.all.last
  end

  def active?
    state.eql?('active')
  end

  def editable?
    !active? and consent_signatures.empty? 
  end

  private
  def default_args
    self.state ||='inactive'
  end
end
