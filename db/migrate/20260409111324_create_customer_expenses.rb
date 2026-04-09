class CreateCustomerExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_expenses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :expense_type
      t.decimal :amount
      t.text :description
      t.string :category

    end
  end
end
