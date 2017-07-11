class AddFileUploadToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :file_upload, :string
  end
end
