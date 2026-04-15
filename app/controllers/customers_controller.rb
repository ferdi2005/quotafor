class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    redirect_to dashboard_path
  end

  def show
    @appointments = @customer.appointments.order(starts_at: :desc)
    @contact_calls = @customer.contact_calls.order(called_at: :desc)
    @referred_customers = @customer.referred_customers.order(:last_name, :first_name)
  end

  def new
    @customer = current_user.customers.new(relationship_started_on: Date.current)
    build_nested_associations
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
    build_nested_associations
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
      :phone,
      :email,
      :prospects,
      :satisfaction_level,
      :annual_income,
      :passions,
      :relationship_started_on,
      :customer_type,
      :personal_summary,
      :active,
      spouses_attributes: %i[id first_name last_name birth_date profession prospects annual_income _destroy],
      children_attributes: %i[id first_name last_name birth_date profession desires solutions annual_income _destroy],
      customer_expenses_attributes: %i[id expense_type amount description category _destroy],
      banks_attributes: %i[id bank_name reason use satisfaction_level what_has deadlines amount rendimento _destroy],
      insurances_attributes: %i[id reason objective amount satisfaction_level rendimento _destroy],
      properties_attributes: %i[id purpose address _destroy]
    )
  end

  def build_nested_associations
    @customer.spouses.build unless @customer.spouses.any?
    @customer.children.build unless @customer.children.any?
    @customer.customer_expenses.build unless @customer.customer_expenses.any?
    @customer.banks.build unless @customer.banks.any?
    @customer.insurances.build unless @customer.insurances.any?
    @customer.properties.build unless @customer.properties.any?
  end
end
