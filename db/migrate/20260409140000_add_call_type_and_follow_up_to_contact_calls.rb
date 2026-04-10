class AddCallTypeAndFollowUpToContactCalls < ActiveRecord::Migration[8.1]
  def up
    add_column :contact_calls, :call_type, :integer, null: false, default: 0 unless column_exists?(:contact_calls, :call_type)

    unless column_exists?(:contact_calls, :generated_from_id)
      add_reference :contact_calls, :generated_from, foreign_key: { to_table: :contact_calls }, index: { unique: true }
    end
  end

  def down
    remove_reference :contact_calls, :generated_from, foreign_key: { to_table: :contact_calls } if column_exists?(:contact_calls, :generated_from_id)
    remove_column :contact_calls, :call_type if column_exists?(:contact_calls, :call_type)
  end
end
