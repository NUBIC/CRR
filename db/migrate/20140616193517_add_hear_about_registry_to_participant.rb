class AddHearAboutRegistryToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :hear_about_registry, :string
  end
end
