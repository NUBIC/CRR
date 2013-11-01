class AddGuardiansToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :primary_guardian_first_name, :string
    add_column :participants, :primary_guardian_last_name, :string
    add_column :participants, :primary_guardian_email, :string
    add_column :participants, :primary_guardian_phone, :string
    add_column :participants, :secondary_guardian_first_name, :string
    add_column :participants, :secondary_guardian_last_name, :string
    add_column :participants, :secondary_guardian_email, :string
    add_column :participants, :secondary_guardian_phone, :string
  end
end