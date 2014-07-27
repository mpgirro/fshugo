class CreateOsxTags < ActiveRecord::Migration
  def change
    create_table :osx_tags do |t|
      t.string :ad
      t.string :tag

      t.timestamps
    end
  end
end
