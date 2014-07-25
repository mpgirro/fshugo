class AddTagsToFilestructureentities < ActiveRecord::Migration
  def change
    add_column :file_structure_entities, :osx_tags, :string
    add_column :file_structure_entities, :fshugo_tags, :string
  end
end
