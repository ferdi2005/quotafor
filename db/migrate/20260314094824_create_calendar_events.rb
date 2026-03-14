class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.integer :category, null: false, default: 0
      t.string :color
      t.string :source_type
      t.bigint :source_id

      t.timestamps
    end

    add_index :calendar_events, [ :source_type, :source_id ]
    add_index :calendar_events, [ :user_id, :starts_at ]
  end
end
