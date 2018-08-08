class AddAncestryDepthToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :ancestry_depth, :integer, default: 0
  end
end
