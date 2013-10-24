class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string    :email
      t.string    :crypted_password
      t.string    :password_salt
      t.string    :persistence_token
      t.integer   :login_count, :default => 0, :null => false
      t.datetime  :last_request_at
      t.datetime  :last_login_at
      t.datetime  :current_login_at
      t.string    :last_login_ip
      t.string    :current_login_ip
      t.string    :perishable_token, :default => '', :null => false
      t.timestamps
    end
    add_index :accounts, :email, :unique => true, :name => 'accounts_email_idx'
  end
end
