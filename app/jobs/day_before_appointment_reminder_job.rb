class DayBeforeAppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform
    target_day = Time.zone.tomorrow.all_day
    Appointment.includes(:user, :customer, :calendar_event).where(starts_at: target_day).find_each do |appointment|
      user = appointment.user
      event = appointment.calendar_event
      next unless event

      already_sent = InAppNotification.where(
        user: user,
        calendar_event: event,
        notification_type: :reminder_day_before
      ).where("created_at >= ?", Time.zone.today.beginning_of_day).exists?

      if already_sent
        Rails.logger.info "[Reminder] Skipped (already sent) for appointment #{appointment.id}"
        next
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

      Rails.logger.info "[Reminder] Sent for appointment #{appointment.id}"
    end
  end
end
