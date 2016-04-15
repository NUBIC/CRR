require 'spec_helper'

describe Study do
  let(:date) { Date.new(2013, 10, 10) }

  it 'creates a new instance given valid attributes' do
    study = FactoryGirl.create(:study)
    expect(study).not_to be_nil
  end

  it { is_expected.to validate_presence_of :state }
  it { is_expected.to have_many(:study_involvements) }
end
