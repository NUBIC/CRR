class CreateConsentSignatures < ActiveRecord::Migration
  def change
    create_table :consent_signatures do |t|
      t.references :consent
      t.references :participant, index: true
      t.date :consent_date
      t.string :consent_person_name
      t.boolean :accept
      t.timestamps
    end
  end
end
