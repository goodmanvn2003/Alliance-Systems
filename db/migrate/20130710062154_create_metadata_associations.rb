class CreateMetadataAssociations < ActiveRecord::Migration
  def change
    create_table :metadata_associations do |t|
      t.integer :srcId
      t.integer :destId

      t.timestamps
    end
  end
end
