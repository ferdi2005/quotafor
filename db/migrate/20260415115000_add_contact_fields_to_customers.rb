class AddContactFieldsToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :phone, :string
    add_column :customers, :email, :string
  end
end
