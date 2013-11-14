# == Schema Information
#
# Table name: surveys
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text
#  state       :text
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Survey < ActiveRecord::Base
  has_many :response_sets,:dependent=>:destroy
  #has_many :questions,:dependent=>:destroy
  has_many :sections, :dependent=>:destroy



  validates_presence_of :title,:state

  validate :activation_check

  def questions
    Question.where("section_id in (?)",sections.collect{|s| s.id})
  end

  def initialize(*args)
    super(*args)
    default_args
  end

  def default_args
    self.state ||= "inactive"
  end

  def active?
    self.state.eql?("active")
  end

  def self.adult_survey
    Survey.where("code ='adult' AND state ='active'").order("created_at DESC").first
  end

  def self.child_survey
    Survey.where("code ='child' AND state ='active'").order("created_at DESC").first
  end

  #this method checks that the survey is in fact valid for activation
  #checks things like it has at least one section, at least one question etc
  def soft_errors
    activation_errors = []
    if sections.size < 1
      activation_errors << "must have at least one section"
    else
      sections.each do |section|
        activation_errors << section.soft_errors
      end
    end
    return activation_errors.flatten.uniq.compact
  end

  def activation_check
    if active?
      errors.add(:survey,soft_errors.to_sentence) unless soft_errors.empty?
    end
  end

end

