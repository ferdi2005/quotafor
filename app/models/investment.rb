class Investment < ApplicationRecord
  belongs_to :customer

  enum :purpose,
       {
         liquidity: "liquidity",
         growth: "growth",
         income: "income",
         retirement: "retirement",
         protection: "protection",
         diversification: "diversification",
         other: "other"
       },
       prefix: true

  validates :product_name, presence: true
end
