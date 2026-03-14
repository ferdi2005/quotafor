class CalendarEvent < ApplicationRecord
  belongs_to :user
  belongs_to :customer, optional: true
  belongs_to :source, polymorphic: true, optional: true
  has_many :in_app_notifications, dependent: :destroy

  enum :category, {
    customer_appointment: 0,
    recurring_activity: 1,
    assistance: 2
  }

  validates :title, :starts_at, :category, presence: true
end
