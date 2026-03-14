class AddReminderTokenToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :reminder_token, :string
  end
end
