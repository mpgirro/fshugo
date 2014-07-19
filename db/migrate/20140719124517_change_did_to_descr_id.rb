class ChangeDidToDescrId < ActiveRecord::Migration
  def change
    remove_column :mime_tabs, :did
    add_column :mime_tabs, :descr_id, :integer
    remove_column :kind_tabs, :did
    add_column :kind_tabs, :descr_id, :integer
  end
end
