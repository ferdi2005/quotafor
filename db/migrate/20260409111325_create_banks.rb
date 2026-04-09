class CreateBanks < ActiveRecord::Migration[8.1]
  def change
    create_table :banks do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :bank_name
      t.text :reason
      t.text :use
      t.integer :satisfaction_level
      t.text :what_has
      t.text :deadlines
      t.decimal :amount

    end
  end
end
