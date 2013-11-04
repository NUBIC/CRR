class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.string :email
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :primary_phone
      t.string :secondary_phone
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zip
      t.string :stage
      t.boolean :do_not_contact
      t.boolean :child
      t.text   :notes
      t.string :primary_guardian_first_name
      t.string :primary_guardian_last_name
      t.string :primary_guardian_email
      t.string :primary_guardian_phone
      t.string :secondary_guardian_first_name
      t.string :secondary_guardian_last_name
      t.string :secondary_guardian_email
      t.string :secondary_guardian_phone
      t.timestamps
    end
  end
end
