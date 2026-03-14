class CreateCustomerObjectives < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_objectives do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :resources
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
