class CreateChildren < ActiveRecord::Migration[8.1]
  def change
    create_table :children do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.integer :age
      t.text :profession
      t.text :desires
      t.text :solutions
      t.decimal :annual_income

    end
  end
end
