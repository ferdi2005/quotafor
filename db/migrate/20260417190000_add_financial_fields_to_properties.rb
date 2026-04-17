class AddFinancialFieldsToProperties < ActiveRecord::Migration[8.1]
  def change
    add_column :properties, :annual_income, :decimal, precision: 12, scale: 2
    add_column :properties, :annual_maintenance_cost, :decimal, precision: 12, scale: 2
    add_column :properties, :commercial_value, :decimal, precision: 12, scale: 2
  end
end
