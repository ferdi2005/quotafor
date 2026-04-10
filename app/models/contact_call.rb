class ContactCall < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  belongs_to :generated_from, class_name: "ContactCall", optional: true
  has_one :follow_up_call, class_name: "ContactCall", foreign_key: :generated_from_id, dependent: :destroy
  has_one :calendar_event, as: :source, dependent: :destroy

  enum :call_type, {
    first_visit: 0,
    second_visit: 1,
    assistance: 2
  }

  validates :called_at, :call_type, presence: true

  after_commit :sync_follow_up_call, on: %i[create update]
  after_commit :sync_calendar_event, on: %i[create update]

  private

  def call_type_color
    {
      "first_visit" => "#198754",
      "second_visit" => "#fd7e14",
      "assistance" => "#0d6efd"
    }.fetch(call_type, "#6c757d")
  end

  def call_type_label
    I18n.t("enums.contact_call.call_type.#{call_type}", default: call_type.to_s.humanize)
  end

  def effective_calendar_start
    return scheduled_for if scheduled_for.present?
    return called_at if generated_from_id.present?

    nil
  end

  def sync_follow_up_call
    if scheduled_for.blank?
      follow_up_call&.destroy
      return
    end

    call = follow_up_call || build_follow_up_call(user: user, customer: customer)
    call.assign_attributes(
      called_at: scheduled_for,
      call_type: call_type,
      notes: nil
    )
    call.save!
  rescue StandardError => e
    Rails.logger.error("Contact call follow-up sync failed for #{id}: #{e.message}")
  end

  def sync_calendar_event
    starts_at = effective_calendar_start

    if starts_at.blank?
      calendar_event&.destroy
      return
    end

    if generated_from_id.blank? && follow_up_call.present?
      calendar_event&.destroy
      return
    end

    event = calendar_event || build_calendar_event(user: user)
    event.assign_attributes(
      customer: customer,
      source: self,
      title: "Telefonata #{call_type_label} - #{customer.full_name}",
      description: notes.presence || "Telefonata di follow-up",
      starts_at: starts_at,
      ends_at: starts_at + 30.minutes,
      category: :customer_appointment,
      color: call_type_color
    )
    event.save!
  rescue StandardError => e
    Rails.logger.error("Contact call calendar sync failed for #{id}: #{e.message}")
  end
end
