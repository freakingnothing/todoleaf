# == Schema Information
#
# Table name: tasks
#
#  id         :bigint(8)        not null, primary key
#  body       :string
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ancestry   :string
#  aasm_state :string
#  aasm_event :string
#

class Task < ApplicationRecord
  include AASM

  aasm do
    state :active, initial: true
    state :done
    state :archived

    event :do_task, after_commit: :change_state_subtasks do
      transitions from: :active, to: :done
    end

    event :archive_task, after_commit: :change_state_subtasks do
      transitions from: [:active, :done], to: :archived, guard: :is_root?
    end

    event :activate_task, after_commit: :change_state_subtasks do
      transitions from: [:done, :archived], to: :active
    end
  end

  def change_state_subtasks
    self.descendants.each do |descendant|
      descendant.aasm_state = aasm.to_state
      descendant.save
    end
  end

  def is_root?
    self.root?
  end

  belongs_to :user
  has_ancestry
  acts_as_taggable
end
