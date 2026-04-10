class CustomerObjective < ApplicationRecord
  belongs_to :customer

  validates :title, presence: true
  validates :invested_resources, :diminished_resources, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  after_commit :refresh_customer_user_rfa_expected

  private

  def refresh_customer_user_rfa_expected
    customer&.user&.refresh_rfa_expected!
  end
end
