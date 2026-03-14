class CustomerObjective < ApplicationRecord
  belongs_to :customer

  validates :title, presence: true
end
