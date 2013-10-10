class AddFlagsToMetadata < ActiveRecord::Migration
  def up
    add_column :metadata, :flags, :integer, :default => 0, :null => false
  end

  def down
    remove_column :metadata, :flags
  end
end
