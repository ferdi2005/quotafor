class AppointmentDayBeforeReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment_id, reminder_token = nil)
    appointment = Appointment.includes(:user, :customer, :calendar_event).find_by(id: appointment_id)
    return unless appointment

    # Skip if a newer reminder was scheduled (token mismatch means this job is stale)
    if reminder_token.present? && appointment.reminder_token != reminder_token
      Rails.logger.info "[Reminder] Skipped (already sent) for appointment #{appointment_id}"
      return
    end

    event = appointment.calendar_event
    user = appointment.user
    return if event.blank? || user.blank?

    return unless appointment.starts_at.between?(Time.zone.tomorrow.beginning_of_day, Time.zone.tomorrow.end_of_day)

    already_sent = InAppNotification.where(
      user: user,
      calendar_event: event,
      notification_type: :reminder_day_before
    ).where("created_at >= ?", Time.zone.today.beginning_of_day).exists?

    if already_sent
      Rails.logger.info "[Reminder] Skipped (already sent) for appointment #{appointment_id}"
      return
    end

    if user.email_notifications?
      AppointmentReminderMailer.day_before(user, event).deliver_later
    end

    if user.in_app_notifications?
      InAppNotification.create!(
        user: user,
        calendar_event: event,
        title: "Promemoria appuntamento domani",
        body: "#{event.title} alle #{I18n.l(event.starts_at, format: :short)}",
        notification_type: :reminder_day_before
      )
    end

    Rails.logger.info "[Reminder] Sent for appointment #{appointment_id}"
  end
end
