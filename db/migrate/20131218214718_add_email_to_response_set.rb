class AddEmailToResponseSet < ActiveRecord::Migration
  def change
    add_column :response_sets, :email, :string
  end
end
