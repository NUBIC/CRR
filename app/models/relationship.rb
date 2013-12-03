# == Schema Information
#
# Table name: relationships
#
#  id             :integer          not null, primary key
#  category       :string(255)
#  origin_id      :integer
#  destination_id :integer
#  notes          :text
#  created_at     :datetime
#  updated_at     :datetime
#

class Relationship < ActiveRecord::Base

  CATEGORIES = ['sibling','spouse','parent','child', 'guardian', 'NA']

  CATEGORIES_DESTINATION_TRANSLATION = {'sibling'=>'sibling','spouse'=>'spouse','parent'=>'child','child'=>'parent', 'guardian'=>'ward', 'NA'=>'NA'}

  belongs_to :origin, :class_name=>"Participant",:foreign_key=>"origin_id"
  belongs_to :destination, :class_name=>"Participant",:foreign_key=>"destination_id"

  validates_presence_of :category, :origin, :destination
  validates_inclusion_of :category, :in => CATEGORIES
end
