class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :invitation_id, :null => false
      t.string :email, :null => false
      t.references :roles
      t.references :sites
      t.boolean :accepted, :null => false, :default => false

      t.timestamps
    end
  end
end
