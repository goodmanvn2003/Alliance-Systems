class CreateRoleUsers < ActiveRecord::Migration
  def up
    create_table :role_users, :id => false do |t|
      t.references  :user
      t.references  :role
    end
  end

  def down
    drop_table :role_users
  end
end

