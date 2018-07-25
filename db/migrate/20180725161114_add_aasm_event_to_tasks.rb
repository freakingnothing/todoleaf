class AddAasmEventToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :aasm_event, :string
  end
end
