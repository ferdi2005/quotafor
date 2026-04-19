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

  test "can store referred customers" do
    promoter = Customer.create!(
      user: users(:one),
      first_name: "Promotore",
      last_name: "Base",
      relationship_started_on: Date.current,
      customer_type: :existing_customer
    )

    referred = promoter.referred_customers.create!(
      user: users(:one),
      first_name: "Prospect",
      last_name: "Referral",
      relationship_started_on: Date.current,
      customer_type: :new_customer
    )

    assert_equal promoter, referred.referred_by_customer
    assert_includes promoter.referred_customers, referred
  end

  test "contracts_count counts investments plus open current account" do
    customer = Customer.create!(
      user: users(:one),
      first_name: "Mario",
      last_name: "Rossi",
      relationship_started_on: Date.current,
      customer_type: :existing_customer,
      ok_current_account: true
    )

    customer.investments.create!(product_name: "Fondo A", with_me: true, amount: 100)
    customer.investments.create!(product_name: "Fondo B", with_me: false, amount: 200)

    assert_equal 3, customer.contracts_count
  end

  test "contracts_count equals investments count when current account is closed" do
    customer = Customer.create!(
      user: users(:one),
      first_name: "Luisa",
      last_name: "Bianchi",
      relationship_started_on: Date.current,
      customer_type: :existing_customer,
      ok_current_account: false
    )

    customer.investments.create!(product_name: "Fondo C", with_me: true, amount: 100)

    assert_equal 1, customer.contracts_count
  end
end
