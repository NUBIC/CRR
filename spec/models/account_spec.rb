# == Schema Information
#
# Table name: accounts
#
#  id                :integer          not null, primary key
#  email             :string(255)
#  crypted_password  :string(255)
#  password_salt     :string(255)
#  persistence_token :string(255)
#  login_count       :integer          default(0), not null
#  last_request_at   :datetime
#  last_login_at     :datetime
#  current_login_at  :datetime
#  last_login_ip     :string(255)
#  current_login_ip  :string(255)
#  perishable_token  :string(255)      default(""), not null
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe Account do
  let(:account) { FactoryGirl.create(:account) }
  it "creates a new instance given valid attributes" do
    account.should_not be_nil
  end

  subject { account }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
  it { should have_many(:account_participants) }
  it { should have_many(:participants) }

  before(:each) do
    @p1 = FactoryGirl.create(:participant, stage: :survey, account: account)
    @p2 = FactoryGirl.create(:participant, stage: :completed, account: account)
    @p3 = FactoryGirl.create(:participant, stage: :pending_approval, account: account)
    @p4 = FactoryGirl.create(:participant, stage: :approved, account: account)
    @p5 = FactoryGirl.create(:participant, stage: :new, account: account)
    @p6 = FactoryGirl.create(:participant, stage: :consent, account: account)
    @p7 = FactoryGirl.create(:participant, stage: :demographics, account: account)
    @p8 = FactoryGirl.create(:participant, stage: :withdrawn, account: account)
    @p9 = FactoryGirl.create(:participant, stage: :consent_denied, account: account)
  end

  describe '#all_participants' do
    it "should include all the participants except 'withdrawn'" do
      account.all_participants(&:stage).should_not include :withdrawn
    end
  end

  describe '#active_participants' do
    it "should include active participants" do
      account.active_participants.should include @p1, @p2, @p3, @p4
    end

    it "should not include inactive participants" do
      account.active_participants.should_not include @p5, @p6, @p7, @p9
    end
  end

  describe '#inactive_participants' do
    it "should include all inactive participants" do
      account.inactive_participants.should include @p5, @p6, @p7, @p9
    end

    it "should not include active participants" do
      account.inactive_participants.should_not include @p1, @p2, @p3, @p4
    end
  end

  describe '#other_participants' do
    it 'should include other participants for that account' do
      account.other_participants(@p1).should include @p2, @p3, @p4
    end

    it 'should not include same participant' do
      account.other_participants(@p1).should_not include @p1
    end

    it 'should not include inactive participants' do
      account.other_participants(@p1).should_not include @p5, @p6, @p7, @p9
    end
  end

  describe '#has_self_participant?' do
    it 'should be true if participant is no proxy participant' do
      account.has_self_participant?.should be_true
    end

    it 'should be false if participant is proxy participant' do
      account.participants.destroy_all
      FactoryGirl.create(:account_participant, :participant => FactoryGirl.create(:participant, stage: :survey),
        account: account, proxy: true)
      account.has_self_participant?.should be_false
    end

    it 'should be false if participant is withdrawn participant' do
      account.participants.destroy_all
      FactoryGirl.create(:account_participant, :participant => FactoryGirl.create(:participant, stage: :withdrawn), account: account)
      account.has_self_participant?.should be_false
    end
  end

  describe '#child_proxy_particpant' do
    it 'should return first participant with child flag true and proxy flag false' do
      par = FactoryGirl.create(:participant, stage: :survey, child: true)
      FactoryGirl.create(:account_participant, :participant => par, account: account, proxy: true)
      account.child_proxy_participant.should == par
    end

    it 'should be nil if no child participants in account' do
      account.child_proxy_participant.should be_nil
    end

    it 'should be nil if no proxy participants in account' do
      account.child_proxy_participant.should be_nil
    end
  end

  describe '#adult_proxy_particpant' do
    it 'should return first adult participant with child flag false and proxy flag true' do
      par = FactoryGirl.create(:participant, stage: :survey, child: false)
      FactoryGirl.create(:account_participant, :participant => @par, account: account, proxy: true)
      account.adult_proxy_participant.should == @par
    end

    it 'should be nil if no adult participants in account' do
      account.adult_proxy_participant.should be_nil
    end

    it 'should be nil if no proxy participants in account' do
      par = FactoryGirl.create(:participant, stage: :survey, child: false)
      FactoryGirl.create(:account_participant, :participant => @par, account: account, proxy: false)
      account.adult_proxy_participant.should be_nil
    end
  end
end
