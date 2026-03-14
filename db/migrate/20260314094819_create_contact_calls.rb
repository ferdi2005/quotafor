class CreateContactCalls < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_calls do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :called_at, null: false
      t.datetime :scheduled_for
      t.text :notes

      t.timestamps
    end
  end
end
