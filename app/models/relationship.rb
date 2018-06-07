class Relationship < ApplicationRecord
  # Globals
  CATEGORIES = ['Sibling or Half sibling', 'Child', 'Parent', 'Guardian', 'Spouse', 'Not Applicable'].freeze
  CATEGORIES_DESTINATION_TRANSLATION = {
    'Sibling or Half sibling' => 'Sibling or Half sibling',
    'Spouse'                  => 'Spouse',
    'Parent'                  => 'Child',
    'Child'                   => 'Parent',
    'Guardian'                => 'Ward',
    'Not Applicable'          => 'Not Applicable'
  }.freeze

  # Associations
  belongs_to :origin,       class_name: 'Participant', foreign_key: :origin_id,       counter_cache: :origin_relationships_count
  belongs_to :destination,  class_name: 'Participant', foreign_key: :destination_id,  counter_cache: :destination_relationships_count

  # Validations
  validates_presence_of :category, :origin, :destination
  validates_inclusion_of :category, in: CATEGORIES
end
