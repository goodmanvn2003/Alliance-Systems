class AddActiveToUsers < ActiveRecord::Migration
  def up
    add_column :users, :active, :boolean, :default => false, :null => false
  end

  def down
    remove_column :users, :active
  end
end
