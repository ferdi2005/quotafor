class Property < ApplicationRecord
  belongs_to :customer

  validates :purpose, :address, presence: true

  enum :purpose, { instrumental: 0, investment: 1 }
end
