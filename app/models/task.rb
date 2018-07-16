class Task < ApplicationRecord
  belongs_to :user
  has_ancestry
end
