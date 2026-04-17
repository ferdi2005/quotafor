class RemoveLegacyFieldsFromInvestments < ActiveRecord::Migration[8.1]
  def change
    remove_column :investments, :investment_type, :string
    remove_column :investments, :bank_name, :string
    remove_column :investments, :deadlines, :text
  end
end
