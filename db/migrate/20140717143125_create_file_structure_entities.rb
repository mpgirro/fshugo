class CreateFileStructureEntities < ActiveRecord::Migration
  def change
    create_table :file_structure_entities do |t|
      t.string :path
      t.integer :bytes
      t.datetime :ctime
      t.datetime :mtime
      t.string :type

      t.timestamps
    end
  end
end
