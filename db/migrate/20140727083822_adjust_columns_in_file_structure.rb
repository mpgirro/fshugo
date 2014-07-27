class AdjustColumnsInFileStructure < ActiveRecord::Migration
  def change
    remove_column :file_structures, :mime_id
    add_column :file_structures, :mimetype, :integer
    
    remove_column :file_structures, :kind_id
    add_column :file_structures, :magicdescr, :integer
  end
end
