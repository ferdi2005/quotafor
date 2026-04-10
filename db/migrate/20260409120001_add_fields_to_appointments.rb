class AddFieldsToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :ok_current_account, :boolean, null: false, default: false
    add_column :appointments, :awaiting_bank_transfer, :boolean, null: false, default: false
    add_column :appointments, :awaiting_bank_transfer_amount, :decimal, precision: 10, scale: 2
    add_column :appointments, :next_appointment_callback, :boolean, null: false, default: false
  end
end
