class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.integer :appointment_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :outcome
      t.text :negative_reason
      t.text :visit_feedback
      t.text :presentation_notes
      t.text :invested_resources
      t.text :deadlines
      t.text :referrals
      t.datetime :next_appointment_at
      t.text :assistance_goal
      t.text :technical_analysis
      t.text :proposed_changes

      t.timestamps
    end

    add_index :appointments, [ :user_id, :starts_at ]
    add_index :appointments, [ :customer_id, :starts_at ]
  end
end
