class CreateSites < ActiveRecord::Migration
  def up
    create_table :sites do |t|
      t.string :sites_id

      t.timestamps
    end

    add_index :sites, :sites_id, :unique => true
  end

  def down
    drop_table :sites
  end
end
