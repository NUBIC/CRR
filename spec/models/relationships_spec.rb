require 'spec_helper'

describe Relationship do
  let(:relationship) { FactoryGirl.create(:relationship) }
  it "creates a new instance given valid attributes" do
    relationship.should_not be_nil
  end

  it { should validate_presence_of :category }
  it { should validate_presence_of :origin }
  it { should validate_presence_of :destination }
  describe 'category' do
    it "should allow valid values" do
      Relationship::CATEGORIES.each do |v|
        should allow_value(v).for(:category)
      end
    end
    it { should_not allow_value("other").for(:category) }
  end
end