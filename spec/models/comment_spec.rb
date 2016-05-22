require 'spec_helper'

describe Comment do
  it { is_expected.to validate_presence_of :content}
  it { is_expected.to belong_to :commentable }
  it { is_expected.to belong_to :user }

  it 'sets default date' do
    comment = Comment.new
    expect(comment.date).not_to be_nil
  end
end