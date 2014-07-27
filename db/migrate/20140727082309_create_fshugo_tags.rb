class CreateFshugoTags < ActiveRecord::Migration
  def change
    create_table :fshugo_tags do |t|
      t.string :ad
      t.string :tag

      t.timestamps
    end
  end
end
