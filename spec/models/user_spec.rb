require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user){ FactoryGirl.create(:user) }

  it { is_expected.to have_many(:user_studies) }
  it { is_expected.to have_many(:studies) }
  it { is_expected.to validate_presence_of(:netid) }

  describe 'with valid user' do
    before(:each) do
      mock_ldap_entry = Net::LDAP::Entry.new()
      mock_ldap_entry['givenname']  = 'Joe'
      mock_ldap_entry['sn']         = 'Doe'
      mock_ldap_entry['mail']       = 'joe@doe.com'

      allow(Devise::LDAP::Adapter).to receive(:valid_login?).and_return(true)
      allow(Devise::LDAP::Adapter).to receive(:get_ldap_entry).and_return(mock_ldap_entry)
    end

    it 'populates user details from LDAP' do

      expect(user.first_name).to eq 'Joe'
      expect(user.last_name).to eq 'Doe'
      expect(user.email).to eq 'joe@doe.com'
    end

    it 'should return full name' do
      expect(user.full_name).to eq 'Joe Doe'
    end
  end
end
