class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.string :cat
      t.string :key
      t.text :value
      t.string :mime

      t.timestamps
    end
  end
end
