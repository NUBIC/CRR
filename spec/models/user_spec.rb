# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  netid              :string(255)
#  admin              :boolean
#  researcher         :boolean
#  data_manager       :boolean
#  first_name         :string(255)
#  last_name          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :inet
#  last_sign_in_ip    :inet
#  email              :string(255)
#

require 'spec_helper'

describe User do
  let(:user){ FactoryGirl.create(:user) }

  it { should have_many(:user_studies) }
  it { should have_many(:studies) }
  it { should validate_presence_of(:netid) }

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
