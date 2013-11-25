class CreateConsentSignatures < ActiveRecord::Migration
  def change
    create_table :consent_signatures do |t|
      t.references :consent
      t.references :participant, index: true
      t.date       :date
      t.string     :proxy_name
      t.string     :entered_by
      t.timestamps
    end
  end
end
