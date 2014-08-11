# == Schema Information
#
# Table name: searches
#
#  id           :integer          not null, primary key
#  study_id     :integer
#  state        :string(255)
#  request_date :date
#  process_date :date
#  decline_date :date
#  start_date   :date
#  warning_date :date
#  end_date     :date
#  name         :string(255)
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe Search do
  let(:search) { FactoryGirl.create(:search) }
  let(:date) { Date.new(2013, 10, 10) }
  it "creates a new instance given valid attributes" do
    search.should_not be_nil
  end

  it { should validate_presence_of :study }

  #describe 'connector' do
  #  it "should allow valid values" do
  #    Search::CONNECTORS.each do |v|
  #      should allow_value(v).for(:operator)
  #    end
  #  end
  #  it { should_not allow_value("other").for(:connector) }
  #end
  
end
