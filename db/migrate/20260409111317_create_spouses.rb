class CreateSpouses < ActiveRecord::Migration[8.1]
  def change
    create_table :spouses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.integer :age
      t.string :profession
      t.text :prospects
      t.decimal :annual_income

    end
  end
end
