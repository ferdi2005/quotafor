class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer
  before_action :set_appointment, only: %i[edit update destroy]

  def new
    @appointment = @customer.appointments.new(user: current_user, starts_at: Time.current.change(min: 0))
  end

  def create
    @appointment = @customer.appointments.new(appointment_params.merge(user: current_user))

    if @appointment.save
      redirect_to customer_path(@customer), notice: "Appuntamento creato e inserito in calendario."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
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
      :presentation_notes,
      :invested_resources,
      :deadlines,
      :referrals,
      :next_appointment_at,
      :assistance_goal,
      :technical_analysis,
      :proposed_changes
    )
  end
end
