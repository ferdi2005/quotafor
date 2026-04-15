class AddOkCurrentAccountToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :ok_current_account, :boolean, null: false, default: false
  end
end
