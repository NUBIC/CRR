# == Schema Information
#
# Table name: participants
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  first_name      :string(255)
#  middle_name     :string(255)
#  last_name       :string(255)
#  primary_phone   :string(255)
#  secondary_phone :string(255)
#  address_line1   :string(255)
#  address_line2   :string(255)
#  city            :string(255)
#  state           :string(255)
#  zip             :string(255)
#  do_not_contact  :boolean
#  notes           :text
#  created_at      :datetime
#  updated_at      :datetime
#

class Participant < ActiveRecord::Base
  has_many :response_sets
  has_many :contact_logs
  has_many :study_involvements
  has_many :origin_relationships,:class_name=>"Relationship",:foreign_key=>"origin_id"
  has_many :destination_relationships,:class_name=>"Relationship",:foreign_key=>"destination_id"

  validates_presence_of :first_name, :last_name
  validates :email, :format => {:with =>/\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i }, allow_blank: true
  validates :primary_phone, :secondary_phone, :format => {:with =>/\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/}, allow_blank: true
  validates :zip, :numericality => true, allow_blank: true, :length => { :maximum => 5 }

  scope :search , proc {|param|
    where("first_name ilike ? or last_name ilike ? ","%#{param}%","%#{param}%")}

  # condensed form of name
  def name
    [first_name, last_name].join(' ')
  end

  def relationships
    origin_relationships + destination_relationships
  end

  # condensed form of address
  def address
    addr = [address_line1, address_line2, city].reject(&:blank?).join(' ').strip
    addr1 = [state, zip].reject(&:blank?).join(' ').strip
    addr1.blank? ? addr.blank? ? nil : addr : addr << "," << addr1
  end

  def on_study?
    study_involvements.where("start_date <= '#{Date.today}' and (end_date is null or end_date > '#{Date.today}')").count > 0
  end

  def search_display
    [name, address, email, primary_phone].reject{|r| r.blank?}.join(' - ').strip
  end

end
