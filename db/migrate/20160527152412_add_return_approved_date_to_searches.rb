class AddReturnApprovedDateToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :return_approved_date, :date
  end
end
