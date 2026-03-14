class CalendarFeedsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :show
  before_action :authenticate_user!, only: :regenerate_token

  def show
    user = User.find_by(calendar_feed_token: params[:token])
    return head :not_found unless user

    events = user.calendar_events.order(:starts_at)

    render plain: to_ics(user, events), content_type: "text/calendar"
  end

  def regenerate_token
    current_user.regenerate_feed_token!
    redirect_to calendar_events_path, notice: "Token calendario rigenerato con successo."
  end

  private

  def to_ics(user, events)
    lines = []
    lines << "BEGIN:VCALENDAR"
    lines << "VERSION:2.0"
    lines << "PRODID:-//QuotaFor//CRM Calendar//IT"
    lines << "CALSCALE:GREGORIAN"
    lines << "X-WR-TIMEZONE:Europe/Rome"
    lines << "X-WR-CALNAME:QuotaFor - #{escape_ics(user.email)}"

    events.each do |event|
      lines << "BEGIN:VEVENT"
      lines << "UID:calendar-event-#{event.id}@quotafor"
      lines << "DTSTAMP:#{event.updated_at.utc.strftime('%Y%m%dT%H%M%SZ')}"
      lines << "DTSTART:#{event.starts_at.utc.strftime('%Y%m%dT%H%M%SZ')}"
      if event.ends_at.present?
        lines << "DTEND:#{event.ends_at.utc.strftime('%Y%m%dT%H%M%SZ')}"
      end
      lines << "SUMMARY:#{escape_ics(event.title)}"
      lines << "DESCRIPTION:#{escape_ics(event.description.to_s)}"
      lines << "END:VEVENT"
    end

    lines << "END:VCALENDAR"
    "#{lines.join("\r\n")}\r\n"
  end

  def escape_ics(text)
    text.to_s
        .gsub("\\", "\\\\")
        .gsub(";", "\\;")
        .gsub(",", "\\,")
        .gsub("\r\n", "\\n")
        .gsub("\n", "\\n")
  end
end
