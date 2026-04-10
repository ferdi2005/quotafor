class ChangeRecurringActivityTopicToText < ActiveRecord::Migration[8.0]
  TOPIC_MAP = {
    0 => "Phone calls",
    1 => "Study",
    2 => "Visit preparation",
    3 => "One to one meeting",
    4 => "Team meeting",
    5 => "Area plenary",
    6 => "Personal administration",
    7 => "Personal space"
  }.freeze

  class MigrationRecurringActivity < ApplicationRecord
    self.table_name = "recurring_activities"
  end

  def up
    add_column :recurring_activities, :topic_text, :string
    MigrationRecurringActivity.reset_column_information

    TOPIC_MAP.each do |value, text|
      MigrationRecurringActivity.where(topic: value).update_all(topic_text: text)
    end

    remove_column :recurring_activities, :topic, :integer
    rename_column :recurring_activities, :topic_text, :topic
    change_column_null :recurring_activities, :topic, false
  end

  def down
    add_column :recurring_activities, :topic_enum, :integer, default: 0, null: false
    MigrationRecurringActivity.reset_column_information

    TOPIC_MAP.each do |value, text|
      MigrationRecurringActivity.where(topic: text).update_all(topic_enum: value)
    end

    remove_column :recurring_activities, :topic, :string
    rename_column :recurring_activities, :topic_enum, :topic
    change_column_default :recurring_activities, :topic, from: 0, to: 0
  end
end
