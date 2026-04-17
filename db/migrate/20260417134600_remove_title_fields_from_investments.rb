class RemoveTitleFieldsFromInvestments < ActiveRecord::Migration[8.1]
  def change
    remove_column :investments, :isin, :string
    remove_column :investments, :initial_capital, :decimal
    remove_column :investments, :rendimento, :decimal
    remove_column :investments, :expires_on, :date
  end
end
