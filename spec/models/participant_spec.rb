require 'spec_helper'

describe Participant do
  let(:participant) { FactoryGirl.create(:participant) }
  it "creates a new instance given valid attributes" do
    participant.should_not be_nil
  end

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should have_many(:origin_relationships) }
  it { should have_many(:destination_relationships) }
  it { should ensure_length_of(:zip).is_at_most(5) }
  it { should validate_numericality_of(:zip) }

  describe '#name' do
    it 'joins first name and last name' do
      participant = FactoryGirl.build(:participant)
      participant.name.should == "Brian Lee"
    end
  end
  
  describe '#address' do
    [
      ['123 Main St', 'Apt #111', 'Chicago', 'IL', '12345', "prints out correctly with all field", "123 Main St Apt #111 Chicago,IL 12345"],
      [nil, 'Apt #111', 'Chicago', 'IL', '12345', "prints out correctly with striping out empty 'address line1'", "Apt #111 Chicago,IL 12345" ],
      ['123 Main St', '', 'Chicago', 'IL', '12345', "prints out correctly with striping out empty 'address line2'", "123 Main St Chicago,IL 12345"],
      ['123 Main St', 'Apt #111', '', 'IL', '12345', "prints out correctly with striping out empty 'city'", "123 Main St Apt #111,IL 12345"],
      ['123 Main St', 'Apt #111', 'Chicago', '', '12345', "prints out correctly with striping out empty 'state'", "123 Main St Apt #111 Chicago,12345"],
      ['123 Main St', 'Apt #111', 'Chicago', 'IL', nil, "prints out correctly with striping out empty 'zip'", "123 Main St Apt #111 Chicago,IL"],
      ['123 Main St', 'Apt #111', 'Chicago', '', nil, "prints out correctly with striping out empty 'state' and 'zip'", "123 Main St Apt #111 Chicago"]
    ].each do |a_1, a_2, c, s, z, test, result|
      it '#{test}' do
        participant = FactoryGirl.build(:participant, address_line1: a_1, address_line2: a_2, city: c, state: s, zip: z)
        participant.address.should == "#{result}"
      end
    end

    it "returns nil for all nil or empty address field" do
      participant = FactoryGirl.build(:participant)
      participant.address.should == nil
    end
  end

  describe '#seach_display' do
    it "includes names" do
      participant = FactoryGirl.build(:participant)
      participant.search_display.should == "Brian Lee"
    end

    it "includes names and address" do
      participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345')
      participant.search_display.should == "Brian Lee - 123 Main St Apt #111 Chicago,IL 12345"
    end

    it "includes names, address and email" do
      participant = participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345', email: 'email@test.com')
      participant.search_display.should == "Brian Lee - 123 Main St Apt #111 Chicago,IL 12345 - email@test.com"
    end

    it "includes names" do
      participant = FactoryGirl.build(:participant, address_line1: '123 Main St', address_line2: 'Apt #111', city: 'Chicago', state: 'IL', zip: '12345', email: 'email@test.com', primary_phone: '1234567890')
      participant.search_display.should == "Brian Lee - 123 Main St Apt #111 Chicago,IL 12345 - email@test.com - 1234567890"
    end
  end

  describe '#validates' do
    [
    '(123) 456 7899',
    '(123).456.7899',
    '(123)-456-7899',
    '123-456-7899',
    '123 456 7899',
    '1234567899',
    ].each do |phone|
      it "allows #{phone} as valid primary_phone" do
        participant = FactoryGirl.create(:participant, primary_phone: phone)
        participant.should be_valid
      end

      it "allows #{phone} as valid secondary_phone" do
        participant = FactoryGirl.create(:participant, secondary_phone: phone)
        participant.should be_valid
      end
    end

    it 'does not allow phone with alphabets as a valid primary_phone' do
      participant = FactoryGirl.build(:participant, primary_phone: '123ABC3456')
      participant.should_not be_valid
    end

    it 'does not allow phone with alphabets as a valid secondary_phone' do
      participant = FactoryGirl.build(:participant, secondary_phone: '123ABC3456')
      participant.should_not be_valid
    end
  end

  describe '#search' do
    it 'returns all the participant with first_name or last_name with "J"' do
      par1 = FactoryGirl.create(:participant, first_name: 'Jacob')
      par2 = FactoryGirl.create(:participant, last_name: 'jim')
      par3 = FactoryGirl.create(:participant)

      partcipants = Participant.search('j')
      partcipants.should include par1
      partcipants.should include par2
      partcipants.should_not include par3
    end
  end

  describe '#relationships' do
    before(:each) do
      sib1 = FactoryGirl.create(:participant, first_name: 'Jacob')
      sib2 = FactoryGirl.create(:participant)
      parent = FactoryGirl.create(:participant, first_name: 'Martha')

      rel1 = FactoryGirl.create(:relationship, origin: sib1, destination: sib2)
      rel2 = FactoryGirl.create(:relationship, category: 'parent', origin: parent, destination: sib1)
      rel3 = FactoryGirl.create(:relationship, category: 'parent', origin: parent, destination: sib2)
    end

    it 'includes origin_relationships and destination_relationships' do
      relationships = sib1.relationships
      relationships.should include rel1
      relationships.should include rel2
    end

    it 'does not include any other relationships' do
      relationships.should_not include rel3
    end
  end
end