class CreateMagicDescriptions < ActiveRecord::Migration
  def change
    create_table :magic_descriptions do |t|
      t.string :ad
      t.string :magicdescr

      t.timestamps
    end
  end
end
