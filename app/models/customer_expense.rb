class CustomerExpense < ApplicationRecord
  belongs_to :customer

  validates :expense_type, :amount, presence: true

  enum :category, { utilities: 0, light: 1, gas: 2, condominium: 3, tv: 4, subscriptions: 5, misc: 6, waste: 7, taxes: 8, weekend: 9, dinners: 10, celebrations: 11, birthdays: 12, vacations: 13 }
end
