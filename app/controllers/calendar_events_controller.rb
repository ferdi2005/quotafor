class CalendarEventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @range = params[:range].presence_in(%w[day week month next_month]) || "month"
    @kind = params[:kind].presence_in(%w[all customer_data activities appointments]) || "all"
    default_from, default_to = default_period(@range)

    @date_from = parse_calendar_date(params[:date_from]) || default_from
    @date_to = parse_calendar_date(params[:date_to]) || default_to
    @date_from, @date_to = [ @date_from, @date_to ].sort if @date_from > @date_to

    @events = current_user.calendar_events
                          .includes(:customer)
                          .where(starts_at: @date_from.beginning_of_day..@date_to.end_of_day)
                          .order(:starts_at)

    @events = apply_kind_filter(@events)
    @events = apply_appointment_type_filter(@events)

    @feed_url = calendar_feed_url(token: current_user.calendar_feed_token, format: :ics)
    @subscription_url = @feed_url.sub("http://", "webcal://").sub("https://", "webcal://")
    @events_by_day = @events.group_by { |e| e.starts_at.to_date } if params[:view] == "daily"
  end

  private

  def default_period(range)
    now = Time.zone.now
    today = now.to_date

    case range
    when "day"
      [ today, today ]
    when "week"
      [ today.beginning_of_week, today.end_of_week ]
    when "next_month"
      next_month = today.next_month
      [ next_month.beginning_of_month, next_month.end_of_month ]
    else
      [ today, today.end_of_month ]
    end
  end

  def parse_calendar_date(value)
    return if value.blank?

    Date.iso8601(value)
  rescue ArgumentError
    nil
  end

  def apply_kind_filter(scope)
    case @kind
    when "customer_data"
      scope.where.not(customer_id: nil)
    when "activities"
      scope.where(category: :recurring_activity)
    when "appointments"
      scope.where(source_type: "Appointment")
    else
      scope
    end
  end

  def apply_appointment_type_filter(scope)
    return scope unless @kind == "appointments"

    appointment_type = params[:appointment_type].presence
    return scope if appointment_type.blank?
    return scope unless Appointment.appointment_types.key?(appointment_type)

    appointment_ids = current_user.appointments.where(appointment_type: appointment_type).select(:id)
    scope.where(source_id: appointment_ids)
  end
end
