class AddTimestampsToSearch < ActiveRecord::Migration
  def change
    add_timestamps(:searches)
  end
end
