class Search < ActiveRecord::Base
  belongs_to :search
  serialize :parameters, Hash
  validates_presence_of :connector, :parameters
  def result
    enrolled = Participant.all
    responses = Response.where("answer_id in (#{parameters.keys.join(",")})") unless parameters.nil?
    return [] if responses.nil?
    if connector == "or"
      @participants = responses.collect{|r| r.response_set.participant if enrolled.include?(r.response_set.participant)}
    elsif connector == "and"
      answer_ids_to_include = parameters.keys.to_a
      @participants = responses.collect{|r| r.response_set.participant if (enrolled.include?(r.response_set.participant) && r.response_set.participant && response_set_includes_all_of(r.response_set, answer_ids_to_include))}
    end
    
    @participants.uniq.compact
  end
  private
    def response_set_includes_all_of(response_set, answer_ids)
      answer_ids_in_responses = response_set.responses.collect{|r| r.answer_id.to_s}
      answer_ids.all?{|ai| answer_ids_in_responses.include?(ai) }
    end
end
