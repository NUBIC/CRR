require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user){ FactoryGirl.create(:user, netid: 'test_user') }

  subject { user }
  it { is_expected.to have_many(:user_studies) }
  it { is_expected.to have_many(:studies) }
  it { is_expected.to validate_presence_of(:netid) }
  it { is_expected.to validate_uniqueness_of(:netid).case_insensitive }

  describe 'with valid user' do
    before(:each) do
      mock_ldap_entry = Net::LDAP::Entry.new()
      mock_ldap_entry['givenname']  = 'Joe'
      mock_ldap_entry['sn']         = 'Doe'
      mock_ldap_entry['mail']       = 'joe@doe.com'

      allow(Devise::LDAP::Adapter).to receive(:valid_login?).and_return(true)
      allow(Devise::LDAP::Adapter).to receive(:get_ldap_entry).and_return(mock_ldap_entry)
    end

    describe 'assigning studies through study tokens' do
      it 'adds studies to a user' do
        s_1 = FactoryGirl.create(:study)
        s_2 = FactoryGirl.create(:study)
        expect(user.studies).to be_empty

        user.study_tokens = [s_1.id, s_2.id].join(',')
        expect(user.studies).to match_array([s_1, s_2])
      end

      it 'removes studies from a user' do
        s_1 = FactoryGirl.create(:study)
        s_2 = FactoryGirl.create(:study)
        user.studies = [s_1, s_2]
        expect(user.studies).to match_array([s_1, s_2])

        user.study_tokens = ''
        user.save!
        expect(user.reload.studies).to be_empty
      end

      it 'updates user studies' do
        s_1 = FactoryGirl.create(:study)
        s_2 = FactoryGirl.create(:study)
        s_3 = FactoryGirl.create(:study)
        user.studies = [s_1, s_2]

        user.study_tokens = [s_1.id, s_3.id].join(',')
        expect(user.reload.studies).to match_array([s_1, s_3])
      end
    end

    it 'returns full name' do
      expect(user.full_name).to eq 'Joe Doe'
    end

    it 'populates user details from LDAP' do
      expect(user.first_name).to eq 'Joe'
      expect(user.last_name).to eq 'Doe'
      expect(user.email).to eq 'joe@doe.com'
    end

    it 'returns active participant for associated studies' do
      s_1 = FactoryGirl.create(:study, state: 'active')
      s_2 = FactoryGirl.create(:study)
      s_3 = FactoryGirl.create(:study)
      user.studies = [s_1, s_2]

      study_involvement_1 = FactoryGirl.create(:study_involvement, study: s_1, end_date: Date.today + 2.days)
      study_involvement_2 = FactoryGirl.create(:study_involvement, study: s_2, end_date: Date.today + 2.days)
      study_involvement_3 = FactoryGirl.create(:study_involvement, study: s_3, end_date: Date.today + 2.days)
      FactoryGirl.create(:study_involvement, study: s_1)
      FactoryGirl.create(:study_involvement, study: s_2)
      FactoryGirl.create(:study_involvement, study: s_3)

      expect(user.reload.active_participants).to match_array([study_involvement_1.participant])
    end

    it 'checks if user has system access' do
      expect(user).to have_system_access

      user.deactivate
      user.save!

      expect(user).not_to have_system_access
    end

    it 'checks if user is active for authentication' do
      expect(user).to be_active_for_authentication

      user.deactivate
      user.save!

      expect(user).not_to be_active_for_authentication
    end
  end
end
