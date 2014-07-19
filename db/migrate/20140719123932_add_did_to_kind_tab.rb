class AddDidToKindTab < ActiveRecord::Migration
  def change
    add_column :kind_tabs, :did, :integer
  end
end
