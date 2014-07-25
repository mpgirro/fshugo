class CreateFshugoTabs < ActiveRecord::Migration
  def change
    create_table :fshugo_tabs do |t|
      t.string :description

      t.timestamps
    end
  end
end
