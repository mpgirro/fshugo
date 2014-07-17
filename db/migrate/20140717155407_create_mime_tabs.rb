class CreateMimeTabs < ActiveRecord::Migration
  def change
    create_table :mime_tabs do |t|
      t.integer :id
      t.string :description

      t.timestamps
    end
  end
end
