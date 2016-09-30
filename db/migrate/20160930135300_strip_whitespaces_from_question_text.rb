class StripWhitespacesFromQuestionText < ActiveRecord::Migration
  def change
    Question.all.each do |question|
      question.text = question.text.strip if question.text.present?
    end
  end
end
