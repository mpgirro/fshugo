class CreateOsxTabs < ActiveRecord::Migration
  def change
    create_table :osx_tabs do |t|
      t.string :description

      t.timestamps
    end
  end
end
