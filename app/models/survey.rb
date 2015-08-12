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

class Survey < ActiveRecord::Base
  has_many :response_sets, :dependent=>:restrict_with_exception
  #has_many :questions,:dependent=>:destroy
  has_many :sections, :dependent=>:destroy

  validates_presence_of :title,:state
  validates_uniqueness_of :code, :allow_blank=> true,:if=>:active?

  validate :activation_check
  after_create :create_section, :unless => :multiple_section?

  default_scope {order('state ASC, created_at DESC')}
  after_initialize :default_args

  def questions
    Question.where("section_id in (?)",sections.collect{|s| s.id})
  end

  def active?
    self.state.eql?("active")
  end

  def inactive?
    !active?
  end

  def self.adult_survey
    Survey.where("code ='adult' AND state ='active'").order("created_at DESC").first
  end

  def self.child_survey
    Survey.where("code ='child' AND state ='active'").order("created_at DESC").first
  end

  def self.has_active_survey?
    child_survey and adult_survey
  end

  def deletable?
    !active? and response_sets.empty?
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

  private
  def activation_check
    if active?
      errors.add(:survey,soft_errors.to_sentence) unless soft_errors.empty?
    end
  end
  def create_section
    sections.create(:title=>"questions")
  end
  def default_args
    self.state ||= "inactive"
  end

end

