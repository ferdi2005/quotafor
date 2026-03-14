class CreateInAppNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :in_app_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :calendar_event, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.datetime :read_at
      t.integer :notification_type, null: false, default: 0

      t.timestamps
    end

    add_index :in_app_notifications, [ :user_id, :read_at ]
  end
end
