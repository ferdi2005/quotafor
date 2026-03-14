class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @filters = filter_params
    @customers = current_user.customers.includes(:appointments).order(:last_name, :first_name)

    if @filters[:full_name].present?
      @customers = @customers.by_full_name(@filters[:full_name])
    end

    if @filters[:age].present?
      age = @filters[:age].to_i
      start_date = age.years.ago.to_date
      end_date = (age + 1).years.ago.to_date
      @customers = @customers.where(birth_date: end_date..start_date)
    end

    if @filters[:profession].present?
      @customers = @customers.by_profession(@filters[:profession])
    end

    if @filters[:relationship_started_on].present?
      date = parse_date(@filters[:relationship_started_on])
      @customers = @customers.where(relationship_started_on: date) if date
    end

    if @filters[:customer_type].present? && Customer.customer_types.key?(@filters[:customer_type])
      @customers = @customers.where(customer_type: Customer.customer_types[@filters[:customer_type]])
    end

    if @filters[:next_appointment_on].present?
      date = parse_date(@filters[:next_appointment_on])
      if date
        @customers = @customers.joins(:appointments).where(appointments: { starts_at: date.all_day }).distinct
      end
    end
  end

  private

  def filter_params
    params.fetch(:filters, {}).permit(
      :full_name,
      :age,
      :profession,
      :relationship_started_on,
      :customer_type,
      :next_appointment_on
    )
  end

  def parse_date(raw)
    Date.parse(raw)
  rescue ArgumentError, TypeError
    nil
  end
end
