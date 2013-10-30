class AddTypeToConsents < ActiveRecord::Migration
  def change
    add_column :consents, :consent_type, :string
  end
end
