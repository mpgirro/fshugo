class AddtofileStructure < ActiveRecord::Migration
  def change
    add_column :file_structures, :path, :string
    add_column :file_structures, :bytes, :integer
    add_column :file_structures, :ctime, :datetime
    add_column :file_structures, :mtime, :datetime
    add_column :file_structures, :entity_type, :string
    add_column :file_structures, :file_count, :integer
    add_column :file_structures, :item_count, :integer
    add_column :file_structures, :mime_id, :integer
    add_column :file_structures, :kind_id, :integer
    add_column :file_structures, :osx_tags, :string
    add_column :file_structures, :fshugo_tags, :string
  end
end
