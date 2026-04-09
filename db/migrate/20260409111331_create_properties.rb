class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :purpose
      t.text :address

    end
  end
end
