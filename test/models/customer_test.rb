require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "calculates savings as total income minus total expenses" do
    customer = Customer.create!(
      user: users(:one),
      first_name: "Test",
      last_name: "Customer",
      relationship_started_on: Date.current,
      customer_type: :existing_customer,
      annual_income: 1200
    )

    customer.spouses.create!(first_name: "Anna", last_name: "Verdi", annual_income: 300)
    customer.children.create!(first_name: "Luca", last_name: "Verdi", annual_income: 100)
    customer.customer_expenses.create!(expense_type: "Casa", amount: 450)
    customer.customer_expenses.create!(expense_type: "Auto", amount: 50)

    assert_equal BigDecimal("1600"), customer.total_income
    assert_equal BigDecimal("500"), customer.total_expenses
    assert_equal BigDecimal("1100"), customer.savings
  end
end
