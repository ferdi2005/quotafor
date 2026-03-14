class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birth_date
      t.string :profession
      t.text :passions
      t.date :relationship_started_on, null: false
      t.integer :customer_type, null: false, default: 0
      t.text :personal_summary
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :customers, [ :user_id, :last_name, :first_name ]
    add_index :customers, :profession
  end
end
