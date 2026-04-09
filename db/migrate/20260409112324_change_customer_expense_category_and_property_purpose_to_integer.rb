class ChangeCustomerExpenseCategoryAndPropertyPurposeToInteger < ActiveRecord::Migration[8.1]
  def change
    change_column :customer_expenses, :category, :integer, using: "CASE category WHEN 'utilities' THEN 0 WHEN 'light' THEN 1 WHEN 'gas' THEN 2 WHEN 'condominium' THEN 3 WHEN 'tv' THEN 4 WHEN 'subscriptions' THEN 5 WHEN 'misc' THEN 6 WHEN 'waste' THEN 7 WHEN 'taxes' THEN 8 WHEN 'weekend' THEN 9 WHEN 'dinners' THEN 10 WHEN 'celebrations' THEN 11 WHEN 'birthdays' THEN 12 WHEN 'vacations' THEN 13 ELSE NULL END"
    change_column :properties, :purpose, :integer, using: "CASE purpose WHEN 'instrumental' THEN 0 WHEN 'investment' THEN 1 ELSE NULL END"
  end
end
