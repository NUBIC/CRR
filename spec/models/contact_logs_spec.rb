require 'spec_helper'

describe ContactLog do
  let(:contact_log) { FactoryGirl.create(:contact_log) }
  it "creates a new instance given valid attributes" do
    contact_log.should_not be_nil
  end

  it { should validate_presence_of :participant}
  
  describe 'mode' do
    it "should allow valid values" do
      ContactLog::MODES.each do |v|
        should allow_value(v).for(:mode)
      end
    end
    it { should_not allow_value("other").for(:mode) }
  end
end