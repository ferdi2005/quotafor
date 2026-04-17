class AddActivityDateToRecurringActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :recurring_activities, :activity_date, :date
  end
end
