class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer
  before_action :set_appointment, only: %i[edit update destroy]

  def new
    @appointment = @customer.appointments.new(
      user: current_user,
      starts_at: Time.current.change(min: 0),
      ok_current_account: @customer.ok_current_account
    )
    prepare_referral_customers
  end

  def create
    @appointment = @customer.appointments.new(appointment_params.merge(user: current_user))
    prepare_referral_customers

    if save_appointment_and_referrals
      redirect_to customer_path(@customer), notice: "Appuntamento creato e inserito in calendario."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_referral_customers
  end

  def update
    @appointment.assign_attributes(appointment_params)
    prepare_referral_customers

    if save_appointment_and_referrals
      redirect_to customer_path(@customer), notice: "Appuntamento aggiornato e sincronizzato nel calendario."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.destroy
    redirect_to customer_path(@customer), notice: "Appuntamento eliminato."
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:customer_id])
  end

  def set_appointment
    @appointment = @customer.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(
      :starts_at,
      :ends_at,
      :appointment_type,
      :status,
      :outcome,
      :negative_reason,
      :visit_feedback,
      :invested_resources,
      :presentation_notes,
      :referrals,
      :next_appointment_at,
      :next_appointment_callback,
      :ok_current_account,
      :awaiting_bank_transfer,
      :awaiting_bank_transfer_amount,
      :assistance_goal,
      :technical_analysis,
      :proposed_changes
    )
  end

  def referral_customer_params
    referral_customer_params_list.first || ActionController::Parameters.new
  end

  def referral_customer_params_list
    appointment_params = params[:appointment]
    return [] unless appointment_params.present?

    permitted_appointment = if appointment_params.is_a?(ActionController::Parameters)
      appointment_params
    else
      ActionController::Parameters.new(appointment_params)
    end

    referral_entries = permitted_appointment.permit(
      referral_customers: [
        :first_name,
        :last_name,
        :birth_date,
        :profession,
        :phone,
        :email,
        :personal_summary,
        :prospects,
        :satisfaction_level
      ]
    ).fetch(:referral_customers, {})

    referral_entries.values.filter_map do |permitted|
      next if permitted.values.all?(&:blank?)

      permitted
    end
  end

  def build_referral_customers
    referral_customer_params_list.map do |attributes|
      current_user.customers.new(
        attributes.merge(
          referred_by_customer: @customer,
          relationship_started_on: Date.current,
          customer_type: :new_customer,
          active: true
        )
      )
    end
  end

  def prepare_referral_customers
    @referral_customers_to_save = build_referral_customers
    @referral_customers = @referral_customers_to_save.presence || [ build_blank_referral_customer ]
  end

  def build_blank_referral_customer
    current_user.customers.new(
      referred_by_customer: @customer,
      relationship_started_on: Date.current,
      customer_type: :new_customer,
      active: true
    )
  end

  def save_appointment_and_referrals
    appointment_valid = @appointment.valid?
    referrals_valid = @referral_customers_to_save.all?(&:valid?)

    return false unless appointment_valid && referrals_valid

    Appointment.transaction do
      @appointment.save!
      @customer.update_column(:ok_current_account, @appointment.ok_current_account)
      @referral_customers_to_save.each(&:save!)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
