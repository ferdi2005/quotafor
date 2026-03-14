class InAppNotification < ApplicationRecord
  belongs_to :user
  belongs_to :calendar_event

  enum :notification_type, { reminder_day_before: 0, generic: 1 }

  validates :title, :body, :notification_type, presence: true

  scope :unread, -> { where(read_at: nil) }
end
