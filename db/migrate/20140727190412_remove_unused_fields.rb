class RemoveUnusedFields < ActiveRecord::Migration
  def change
    remove_column :fshugo_tags, :ad
    remove_column :fshugo_tags, :created_at
    remove_column :fshugo_tags, :updated_at
    
    remove_column :magic_descriptions, :ad
    remove_column :magic_descriptions, :created_at
    remove_column :magic_descriptions, :updated_at
    
    remove_column :mime_types, :ad
    remove_column :mime_types, :created_at
    remove_column :mime_types, :updated_at
    
    remove_column :osx_tags, :ad
    remove_column :osx_tags, :created_at
    remove_column :osx_tags, :updated_at
  end
end
