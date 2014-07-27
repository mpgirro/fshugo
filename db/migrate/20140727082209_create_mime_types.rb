class CreateMimeTypes < ActiveRecord::Migration
  def change
    create_table :mime_types do |t|
      t.string :ad
      t.string :mimetype

      t.timestamps
    end
  end
end
