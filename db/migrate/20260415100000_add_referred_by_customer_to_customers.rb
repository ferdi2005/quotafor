class AddReferredByCustomerToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_reference :customers,
                  :referred_by_customer,
                  foreign_key: { to_table: :customers },
                  index: true
  end
end
