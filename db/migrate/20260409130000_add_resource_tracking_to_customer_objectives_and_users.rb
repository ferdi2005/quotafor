class AddResourceTrackingToCustomerObjectivesAndUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :customer_objectives, :invested_resources, :decimal, precision: 12, scale: 2
    add_column :customer_objectives, :diminished_resources, :decimal, precision: 12, scale: 2

    add_column :users, :rfa_expected, :decimal, precision: 12, scale: 2, null: false, default: 0
  end
end
