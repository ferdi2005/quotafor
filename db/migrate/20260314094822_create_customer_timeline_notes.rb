class CreateCustomerTimelineNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_timeline_notes do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :happened_at, null: false
      t.integer :category, null: false, default: 0
      t.text :content, null: false

      t.timestamps
    end
  end
end
