require "icalendar"
require "icalendar/tzinfo"

class CalendarFeedsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :show
  before_action :authenticate_user!, only: :regenerate_token

  def show
    user = User.find_by(calendar_feed_token: params[:token])
    return head :not_found unless user

    events = user.calendar_events.order(:starts_at)
    calendar = build_calendar(user, events)
    response.headers["Content-Disposition"] = %(inline; filename="quotafor-calendar.ics")

    render body: calendar.to_ical, content_type: "text/calendar; charset=utf-8"
    response.headers["Content-Type"] = "text/calendar; charset=utf-8; method=PUBLISH"
  end

  def regenerate_token
    current_user.regenerate_feed_token!
    redirect_to calendar_events_path, notice: "Token calendario rigenerato con successo."
  end

  private

  def build_calendar(user, events)
    zone_name = calendar_time_zone_name(user)
    calendar = Icalendar::Calendar.new
    calendar.prodid = "-//QuotaFor//CRM Calendar//IT"
    calendar.version = "2.0"
    calendar.calscale = "GREGORIAN"
    calendar.publish
    calendar.ip_name = "QuotaFor - #{user.email}"
    calendar.x_wr_calname = "QuotaFor - #{user.email}"
    calendar.x_wr_timezone = zone_name
    calendar.refresh_interval = "P1D"
    calendar.x_published_ttl = "P1D"

    add_timezone_component(calendar, zone_name, events)

    events.each do |event|
      calendar.add_event build_event(event, zone_name)
    end

    calendar
  end

  def build_event(event, zone_name)
    Icalendar::Event.new.tap do |ical_event|
      ical_event.uid = "calendar-event-#{event.id}@#{calendar_uid_host}"
      ical_event.dtstamp = Icalendar::Values::DateTime.new(event.updated_at.utc, "tzid" => "UTC")

      start_time = event.starts_at.in_time_zone(zone_name)
      ical_event.dtstart = Icalendar::Values::DateTime.new(start_time, "tzid" => zone_name)

      if event.ends_at.present? && event.ends_at > event.starts_at
        end_time = event.ends_at.in_time_zone(zone_name)
        ical_event.dtend = Icalendar::Values::DateTime.new(end_time, "tzid" => zone_name)
      else
        ical_event.duration = "PT1H"
      end

      ical_event.status = "CONFIRMED"
      ical_event.summary = event.title
      ical_event.description = event.description.to_s
    end
  end

  def add_timezone_component(calendar, zone_name, events)
    reference_time = events.first&.starts_at || Time.current
    timezone = TZInfo::Timezone.get(zone_name).ical_timezone(reference_time)
    calendar.add_timezone timezone
  rescue TZInfo::InvalidTimezoneIdentifier
    fallback_zone = "Europe/Rome"
    calendar.x_wr_timezone = fallback_zone
    calendar.add_timezone TZInfo::Timezone.get(fallback_zone).ical_timezone(reference_time)
  end

  def calendar_time_zone_name(user)
    user.time_zone.presence || "Europe/Rome"
  end

  def calendar_uid_host
    request.host.presence || "quotafor.local"
  end
end
