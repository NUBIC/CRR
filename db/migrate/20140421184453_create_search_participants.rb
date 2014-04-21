class CreateSearchParticipants < ActiveRecord::Migration
  def change
    create_table :search_participants do |t|
      t.references :search
      t.references :participant, index: true
      t.boolean :released, default: false, null: false
    end
  end
end