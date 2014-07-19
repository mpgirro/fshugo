class AddDidToMimeTab < ActiveRecord::Migration
  def change
    add_column :mime_tabs, :did, :integer
  end
end
