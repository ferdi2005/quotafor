class CreateInsurances < ActiveRecord::Migration[8.1]
  def change
    create_table :insurances do |t|
      t.references :customer, null: false, foreign_key: true
      t.text :reason
      t.text :objective
      t.decimal :amount
      t.integer :satisfaction_level

    end
  end
end
