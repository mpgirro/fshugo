class CreateFileStructures < ActiveRecord::Migration
  def change
    create_table :file_structures do |t|

      t.timestamps
    end
  end
end
