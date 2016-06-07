class AddReturnCompletedDateToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :return_completed_date, :date
  end
end
