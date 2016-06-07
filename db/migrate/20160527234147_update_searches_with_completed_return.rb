class UpdateSearchesWithCompletedReturn < ActiveRecord::Migration
  def change
    Search.all.each do |search|
      search.complete_data_return! if search.data_released? && search.all_participants_returned? && !search.data_returned?
    end
  end
end
