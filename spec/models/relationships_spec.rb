require 'spec_helper'

describe Relationship do
  let(:relationship) { FactoryGirl.create(:relationship) }
  it 'creates a new instance given valid attributes' do
    expect(relationship).not_to be_nil
  end

  it { is_expected.to validate_presence_of :category }
  it { is_expected.to validate_presence_of :origin }
  it { is_expected.to validate_presence_of :destination }
  describe 'category' do
    it 'should allow valid values' do
      Relationship::CATEGORIES.each do |v|
        is_expected.to allow_value(v).for(:category)
      end
    end
    it { is_expected.not_to allow_value('other').for(:category) }
  end
end