require 'rails_helper'

RSpec.describe SearchParticipantStudyInvolvement, type: :model do
  it { is_expected.to belong_to :search_participant }
  it { is_expected.to belong_to :study_involvement }
  it { is_expected.to accept_nested_attributes_for(:study_involvement) }
end
