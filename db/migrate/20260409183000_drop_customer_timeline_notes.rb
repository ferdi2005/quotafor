class DropCustomerTimelineNotes < ActiveRecord::Migration[8.1]
  def change
    drop_table :customer_timeline_notes, if_exists: true
  end
end