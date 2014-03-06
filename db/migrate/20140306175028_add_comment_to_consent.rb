class AddCommentToConsent < ActiveRecord::Migration
  def change
    add_column :consents, :comment, :text
  end
end
