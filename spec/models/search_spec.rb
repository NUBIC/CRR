require 'rails_helper'

RSpec.describe Search, type: :model do
  let(:search) { FactoryBot.create(:search) }
  let(:date) { Date.new(2013, 10, 10) }
  let(:study) { FactoryBot.create(:study) }
  it 'creates a new instance given valid attributes' do
    expect(search).not_to be_nil
  end

  it { is_expected.to validate_presence_of :study }

  it 'should automatically create a search condition group when a search is created' do
    search = study.searches.create
    expect(search.search_condition_group).not_to be_nil
  end
end
