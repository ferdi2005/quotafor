class Bank < ApplicationRecord
  belongs_to :customer

  validates :bank_name, presence: true
end
