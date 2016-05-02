require 'rails_helper'

RSpec.describe StudyInvolvementState, type: :model do
  it { is_expected.to belong_to :study_involvement }
  it { is_expected.to be_versioned }
  it { is_expected.to validate_inclusion_of(:name).in_array(StudyInvolvementState::VALID_STATES.map{|s| s[:name]}) }
end
