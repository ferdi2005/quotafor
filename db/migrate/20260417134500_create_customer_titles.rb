class CreateCustomerTitles < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_titles do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :title_type
      t.string :isin
      t.decimal :initial_capital
      t.date :expires_on
      t.decimal :rendimento
    end
  end
end
