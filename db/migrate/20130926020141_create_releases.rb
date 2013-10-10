class CreateReleases < ActiveRecord::Migration
  def up
    create_table :releases do |t|
      t.references :metadata
      t.datetime :date_time, :null => true
      t.references :users
    end

    add_index :releases, :metadata_id, :unique => true
  end

  def down
    drop_table :releases
  end
end
