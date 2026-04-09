class Insurance < ApplicationRecord
  belongs_to :customer

  validates :reason, :objective, presence: true
end
