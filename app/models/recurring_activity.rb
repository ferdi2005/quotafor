class RecurringActivity < ApplicationRecord
  belongs_to :user
  has_many :calendar_events, as: :source, dependent: :destroy

  enum :periodicity, { daily: 0, weekly: 1, monthly: 2 }
  enum :weekday, {
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 7
  }

  validates :topic, :weekday, :periodicity, :starts_at, :ends_at, presence: true
  validate :end_after_start

  after_commit :sync_calendar_events, on: %i[create update]

  private

  def end_after_start
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "deve essere successivo all'orario di inizio")
  end

  def sync_calendar_events
    calendar_events.where("starts_at >= ?", Time.zone.now.beginning_of_day).delete_all
    return unless active?

    occurrence_dates.each do |date|
      start_time = Time.zone.local(date.year, date.month, date.day, starts_at.hour, starts_at.min)
      end_time = Time.zone.local(date.year, date.month, date.day, ends_at.hour, ends_at.min)

      calendar_events.create!(
        user: user,
        title: "Attività - #{topic}",
        description: notes.presence || "Attività ricorrente #{topic}",
        starts_at: start_time,
        ends_at: end_time,
        category: :recurring_activity,
        color: recurring_color,
        source: self
      )
    end
  rescue StandardError => e
    Rails.logger.error("Recurring activity sync failed for #{id}: #{e.message}")
  end

  def occurrence_dates
    today = Time.zone.today
    horizon = today + 60.days

    case periodicity
    when "daily"
      (today..horizon).to_a
    when "weekly"
      (today..horizon).select { |date| date.cwday == weekday_before_type_cast }
    when "monthly"
      day = created_at&.to_date&.day || today.day
      months = []
      cursor_month = today.beginning_of_month
      while cursor_month <= horizon
        begin
          occurrence = cursor_month.change(day: day)
        rescue Date::Error, ArgumentError
          occurrence = cursor_month.end_of_month
        end
        months << occurrence if occurrence >= today
        cursor_month = cursor_month.next_month
      end
      months
    else
      []
    end
  end

  def recurring_color
    "#0d6efd"
  end
end
