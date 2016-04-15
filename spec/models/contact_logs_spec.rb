require 'spec_helper'

describe ContactLog do
  let(:contact_log) { FactoryGirl.create(:contact_log) }
  it 'creates a new instance given valid attributes' do
    expect(contact_log).not_to be_nil
  end

  it { is_expected.to validate_presence_of :participant}

  describe 'mode' do
    it 'should allow valid values' do
      ContactLog::MODES.each do |v|
        is_expected.to allow_value(v).for(:mode)
      end
    end
    it { is_expected.not_to allow_value('other').for(:mode) }
  end
end