class AddSiteidToMetadata < ActiveRecord::Migration
  def up
    change_table :metadata do |t|
      t.references :sites
    end
  end

  def down
    # Don't do anything
  end
end
