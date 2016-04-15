require 'spec_helper'

describe Account do
  let(:account) { FactoryGirl.create(:account) }

  it 'creates a new instance given valid attributes' do
    expect(account).not_to be_nil
  end

  subject { account }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_uniqueness_of :email }
  it { is_expected.to have_many(:account_participants) }
  it { is_expected.to have_many(:participants) }

  before(:each) do
    @p1 = FactoryGirl.create(:participant, stage: :survey, account: account)
    @p2 = FactoryGirl.create(:participant, stage: :pending_approval, account: account)
    @p3 = FactoryGirl.create(:participant, stage: :approved, account: account)
    @p4 = FactoryGirl.create(:participant, stage: :consent, account: account)
    @p5 = FactoryGirl.create(:participant, stage: :demographics, account: account)
    @p6 = FactoryGirl.create(:participant, stage: :withdrawn, account: account)
    @p7 = FactoryGirl.create(:participant, stage: :consent_denied, account: account)
  end

  describe '#all_participants' do
    it 'should include all the participants except "withdrawn"' do
      expect(account.all_participants(&:stage)).not_to include :withdrawn
    end
  end

  describe '#active_participants' do
    it 'should include active participants' do
      expect(account.active_participants).to match_array([@p1, @p2, @p3])
    end

    it 'should not include inactive participants' do
      expect(account.active_participants).not_to  include @p4, @p5, @p7
    end
  end

  describe '#inactive_participants' do
    it 'should include all inactive participants' do
      expect(account.inactive_participants).to match_array([@p4, @p5, @p7])
    end

    it 'should not include active participants' do
      expect(account.inactive_participants).not_to include @p1, @p2, @p3
    end
  end

  describe '#other_participants' do
    it 'should include other participants for that account' do
      expect(account.other_participants(@p1)).to match_array([@p2, @p3])
    end

    it 'should not include same participant' do
      expect(account.other_participants(@p1)).not_to include @p1
    end

    it 'should not include inactive participants' do
      expect(account.other_participants(@p1)).not_to include @p4, @p5, @p7
    end
  end

  describe '#has_self_participant?' do
    it 'should be true if participant is no proxy participant' do
      expect(account.has_self_participant?).to be true
    end

    it 'should be false if participant is proxy participant' do
      account.participants.destroy_all
      FactoryGirl.create(:account_participant, :participant => FactoryGirl.create(:participant, stage: :survey),
        account: account, proxy: true)
      expect(account.has_self_participant?).to be false
    end

    it 'should be false if participant is withdrawn participant' do
      account.participants.destroy_all
      FactoryGirl.create(:account_participant, :participant => FactoryGirl.create(:participant, stage: :withdrawn), account: account)
      expect(account.has_self_participant?).to be false
    end
  end

  describe '#child_proxy_particpant' do
    it 'should return first participant with child flag true and proxy flag false' do
      par = FactoryGirl.create(:participant, stage: :survey, child: true)
      FactoryGirl.create(:account_participant, :participant => par, account: account, proxy: true)
      expect(account.child_proxy_participant).to eq par
    end

    it 'should be nil if no child participants in account' do
      expect(account.child_proxy_participant).to be_nil
    end

    it 'should be nil if no proxy participants in account' do
      expect(account.child_proxy_participant).to be_nil
    end
  end

  describe '#adult_proxy_particpant' do
    it 'should return first adult participant with child flag false and proxy flag true' do
      par = FactoryGirl.create(:participant, stage: :survey, child: false)
      FactoryGirl.create(:account_participant, :participant => @par, account: account, proxy: true)
      expect(account.adult_proxy_participant).to eq @par
    end

    it 'should be nil if no adult participants in account' do
      expect(account.adult_proxy_participant).to be_nil
    end

    it 'should be nil if no proxy participants in account' do
      par = FactoryGirl.create(:participant, stage: :survey, child: false)
      FactoryGirl.create(:account_participant, :participant => @par, account: account, proxy: false)
      expect(account.adult_proxy_participant).to be_nil
    end
  end
end
