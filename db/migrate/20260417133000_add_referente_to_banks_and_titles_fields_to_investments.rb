class AddReferenteToBanksAndTitlesFieldsToInvestments < ActiveRecord::Migration[8.1]
  def change
    add_column :banks, :referente, :string

    add_column :investments, :isin, :string
    add_column :investments, :initial_capital, :decimal
    add_column :investments, :rendimento, :decimal
    add_column :investments, :expires_on, :date
  end
end
