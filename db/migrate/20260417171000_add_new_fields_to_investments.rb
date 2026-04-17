class AddNewFieldsToInvestments < ActiveRecord::Migration[8.1]
  def change
    add_column :investments, :product_name, :string
    add_column :investments, :distributed_by, :string
    add_column :investments, :subscription_date, :date
    add_column :investments, :purpose, :string
    add_column :investments, :advised_by, :string
  end
end
