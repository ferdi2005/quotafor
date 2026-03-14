class CreateRecurringActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :topic, null: false, default: 0
      t.integer :weekday, null: false, default: 1
      t.integer :periodicity, null: false, default: 1
      t.time :starts_at, null: false
      t.time :ends_at, null: false
      t.string :location
      t.text :notes
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
