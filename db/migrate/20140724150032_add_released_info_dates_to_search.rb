class AddReleasedInfoDatesToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :start_date, :date
    add_column :searches, :warning_date, :date
    add_column :searches, :end_date, :date
  end
end
