class Relationship < ActiveRecord::Base

  CATEGORIES = ['sibling','spouse','parent','child']

  CATEGORIES_DESTINATION_TRANSLATION={'sibling'=>'sibling','spouse'=>'spouse','parent'=>'child','child'=>'parent'}

  belongs_to :origin, :class_name=>"Participant",:foreign_key=>"origin_id"
  belongs_to :destination, :class_name=>"Participant",:foreign_key=>"destination_id"

end
