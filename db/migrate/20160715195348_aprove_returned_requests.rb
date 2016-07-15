class AproveReturnedRequests < ActiveRecord::Migration
  def change
    Search.returned.each do |search|
      search.process_return_approval
    end
  end
end
