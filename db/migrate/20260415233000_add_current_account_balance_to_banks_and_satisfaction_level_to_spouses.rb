class AddCurrentAccountBalanceToBanksAndSatisfactionLevelToSpouses < ActiveRecord::Migration[8.1]
  def change
    add_column :banks, :current_account_balance, :decimal
    add_column :spouses, :satisfaction_level, :integer
  end
end
