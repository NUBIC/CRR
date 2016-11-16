class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.integer   :user_id, null: false
      t.datetime  :date, null: false
      t.integer   :study_involvement_id, null: false
      t.string    :consent, null: false

      t.timestamps null: false
    end
  end
end
