class AddAasmStateToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :aasm_state, :string
  end
end
