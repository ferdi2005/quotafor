class AddWithMeAndActiveToInvestments < ActiveRecord::Migration[8.1]
  def change
    add_column :investments, :with_me, :boolean, null: false, default: false
    add_column :investments, :active, :boolean, null: false, default: true
  end
end
