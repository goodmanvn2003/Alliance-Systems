class CreateSiteUsers < ActiveRecord::Migration
  def up
    create_table :site_users do |t|
      t.references :sites
      t.references :users
      t.references :roles
      t.boolean :is_owner, :default => false

      t.timestamps
    end
  end

  def down
    drop_table :site_users
  end
end
