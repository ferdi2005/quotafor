class Investment < ApplicationRecord
  belongs_to :customer

  validates :investment_type, :bank_name, presence: true
end
