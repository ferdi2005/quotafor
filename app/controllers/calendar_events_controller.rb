class CalendarEventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = current_user.calendar_events.order(:starts_at)
    @feed_url = calendar_feed_url(token: current_user.calendar_feed_token, format: :ics)
    @events_by_day = @events.group_by { |e| e.starts_at.to_date } if params[:view] == "daily"
  end
end
