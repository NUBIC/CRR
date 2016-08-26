class AddStateToUsers < ActiveRecord::Migration
  def up
    add_column :users, :state, :string

    User.all.each do |user|
      user.validate
      if user.valid?
        user.activate
        user.save!
      else
        puts user.errors.full_messages.inspect
        user.deactivate
        user.save!(validate: false)
      end
    end
  end

  def down
    remove_column :users, :state, :string
  end
end
