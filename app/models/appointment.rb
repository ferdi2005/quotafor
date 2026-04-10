class Appointment < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  has_one :calendar_event, as: :source, dependent: :destroy

  enum :appointment_type, {
    first_meeting: 0,
    follow_up: 1,
    assistance: 2,
    return_meeting: 3
  }
  enum :status, { scheduled: 0, rescheduled: 1, completed: 2, canceled: 3 }
  enum :outcome, { negative: 0, second_visit: 1, postponed: 2, call_back: 3 }, prefix: true

  validates :starts_at, :appointment_type, :status, presence: true
  validates :negative_reason,
            presence: { message: "obbligatorio se l'esito è negativo" },
            if: -> { outcome_negative? }
  validate :ends_at_after_starts_at

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }

  after_commit :sync_calendar_event, on: %i[create update]
  after_commit :schedule_day_before_reminder, on: %i[create update]

  private

  def ends_at_after_starts_at
    return if ends_at.blank? || starts_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "deve essere successiva a inizio appuntamento")
  end

  def sync_calendar_event
    event = calendar_event || build_calendar_event(user: user)
    event.assign_attributes(
      customer: customer,
      source: self,
      title: "Appuntamento - #{customer.full_name}",
      description: visit_feedback.presence || "Appuntamento #{appointment_type.humanize}",
      starts_at: starts_at,
      ends_at: ends_at,
      category: appointment_type == "assistance" ? :assistance : :customer_appointment,
      color: appointment_type == "assistance" ? "#0d6efd" : "#198754"
    )
    event.save!
  rescue StandardError => e
    Rails.logger.error("Calendar sync failed for appointment #{id}: #{e.message}")
  end

  def schedule_day_before_reminder
    return if starts_at.blank?

    run_at = starts_at - 1.day
    return if run_at <= Time.current

    token = SecureRandom.hex(8)
    update_column(:reminder_token, token)
    AppointmentDayBeforeReminderJob.set(wait_until: run_at).perform_later(id, token)
  end
end
