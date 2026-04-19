class AddEndDateToRecurringActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :recurring_activities, :end_date, :date
  end
end
