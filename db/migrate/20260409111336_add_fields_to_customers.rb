class AddFieldsToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :prospects, :text
    add_column :customers, :satisfaction_level, :integer
    add_column :customers, :annual_income, :decimal
  end
end
