class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    redirect_to dashboard_path
  end

  def show
    @appointments = @customer.appointments.order(starts_at: :desc)
    @contact_calls = @customer.contact_calls.order(called_at: :desc)
    @timeline_notes = @customer.customer_timeline_notes.order(happened_at: :desc)
  end

  def new
    @customer = current_user.customers.new(relationship_started_on: Date.current)
  end

  def create
    @customer = current_user.customers.new(customer_params)

    if @customer.save
      redirect_to customer_path(@customer), notice: "Cliente creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to customer_path(@customer), notice: "Cliente aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy
    redirect_to dashboard_path, notice: "Cliente eliminato con successo."
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :first_name,
      :last_name,
      :birth_date,
      :profession,
      :passions,
      :relationship_started_on,
      :customer_type,
      :personal_summary,
      :active
    )
  end
end
