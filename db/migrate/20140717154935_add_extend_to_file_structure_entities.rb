class AddExtendToFileStructureEntities < ActiveRecord::Migration
  def change
    add_column :file_structure_entities, :file_count, :integer
    add_column :file_structure_entities, :item_count, :integer
    add_column :file_structure_entities, :mime_id, :integer
    add_column :file_structure_entities, :kind_id, :integer
  end
end
