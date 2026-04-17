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
  end

  def create
    @appointment = @customer.appointments.new(appointment_params.merge(user: current_user))

    if save_appointment
      redirect_to customer_path(@customer), notice: "Appuntamento creato e inserito in calendario."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @appointment.assign_attributes(appointment_params)

    if save_appointment
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

  def save_appointment
    Appointment.transaction do
      @appointment.save!
      @customer.update_column(:ok_current_account, @appointment.ok_current_account)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
