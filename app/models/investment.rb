class Investment < ApplicationRecord
  belongs_to :customer

  after_commit :refresh_customer_user_rfa_expected

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

  private

  def refresh_customer_user_rfa_expected
    customer&.user&.refresh_rfa_expected!
  end
end
