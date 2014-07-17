class CreateKindTabs < ActiveRecord::Migration
  def change
    create_table :kind_tabs do |t|
      t.integer :id
      t.string :description

      t.timestamps
    end
  end
end
