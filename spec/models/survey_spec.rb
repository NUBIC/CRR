# == Schema Information
#
# Table name: surveys
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  description      :text
#  state            :text
#  code             :string(255)
#  multiple_section :boolean
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe Survey do
  before(:each) do
  end


  it "should create section for surveys that are not multiple sections" do
    survey = FactoryGirl.create(:survey,:multiple_section=>false)
    survey.sections.size.should eq(1)
  end


end
