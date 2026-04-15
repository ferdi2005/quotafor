class CreateInvestments < ActiveRecord::Migration[8.1]
  def change
    create_table :investments do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :investment_type
      t.string :bank_name
      t.text :deadlines
      t.decimal :amount
      t.integer :satisfaction_level
    end
  end
end
