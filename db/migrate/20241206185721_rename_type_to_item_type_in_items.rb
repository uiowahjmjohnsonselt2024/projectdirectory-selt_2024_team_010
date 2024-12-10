class RenameTypeToItemTypeInItems < ActiveRecord::Migration
  def change
    rename_column :items, :type, :item_type
  end
end
