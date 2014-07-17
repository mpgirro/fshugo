class ChangeTypeInFileStructureEntity < ActiveRecord::Migration
  def change
    remove_column :file_structure_entities, :type
    add_column :file_structure_entities, :entity_type, :string
  end
end
