class RemoveDescrid < ActiveRecord::Migration
  def change
    remove_column :mime_tabs, :descr_id
    remove_column :kind_tabs, :descr_id
  end
end
