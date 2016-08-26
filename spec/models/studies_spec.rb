require 'rails_helper'

RSpec.describe Study, type: :model do
  let(:date)  { Date.new(2013, 10, 10) }
  let(:study) { FactoryGirl.create(:study)}

  it { is_expected.to validate_presence_of :state }
  it { is_expected.to have_many(:study_involvements) }

  it 'creates a new instance given valid attributes' do
    expect(study).not_to be_nil
  end

  it 'returns active participants' do
    expect(study.active_participants).to be_empty

    study_involvement = FactoryGirl.create(:study_involvement, study: study)
    expect(study.active_participants).to be_empty

    study_involvement_1 = FactoryGirl.create(:study_involvement, study: study, end_date: Date.today + 2.days)
    expect(study.active_participants).to match_array([study_involvement_1.participant])
  end

  it 'provides search display' do
    expect(study.search_display).to match /#{study.id}/
    expect(study.search_display).to match /#{study.name}/
    expect(study.search_display).to match /#{study.irb_number}/
  end

  it 'returns display name' do
    expect(study.display_name).to eq study.name
    study.short_title = Faker::Lorem.sentence
    expect(study.display_name).to eq study.short_title
  end

  it 'returns user emails' do
    user = User.find_by_netid('test_user')
    user ||= FactoryGirl.create(:user, netid: 'test_user')

    study.users = [user]
    expect(study.user_emails).to match_array([user.email])

    user.deactivate
    user.save!
    expect(study.user_emails).to be_empty
  end
end
