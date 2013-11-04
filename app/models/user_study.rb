# == Schema Information
#
# Table name: user_studies
#
#  id       :integer          not null, primary key
#  user_id  :integer
#  study_id :integer
#


class UserStudy < ActiveRecord::Base

  validates_presence_of :user,:study
  
end
