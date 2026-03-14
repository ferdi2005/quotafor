class ContactCall < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  has_one :calendar_event, as: :source, dependent: :destroy

  validates :called_at, presence: true

  after_commit :sync_calendar_event, on: %i[create update]

  private

  def sync_calendar_event
    if scheduled_for.blank?
      calendar_event&.destroy
      return
    end

    event = calendar_event || build_calendar_event(user: user)
    event.assign_attributes(
      customer: customer,
      source: self,
      title: "Telefonata programmata - #{customer.full_name}",
      description: notes.presence || "Telefonata di follow-up",
      starts_at: scheduled_for,
      ends_at: scheduled_for + 30.minutes,
      category: :customer_appointment,
      color: "#fd7e14"
    )
    event.save!
  rescue StandardError => e
    Rails.logger.error("Contact call calendar sync failed for #{id}: #{e.message}")
  end
end
