class CreateConsents < ActiveRecord::Migration
  def change
    create_table :consents do |t|
      t.text    :content
      t.string  :accept_text, :default => "I Accept"
      t.string  :decline_text,:default=>"I Decline"
      t.timestamps
    end
  end
end
