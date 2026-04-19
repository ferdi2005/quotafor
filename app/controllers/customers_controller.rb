class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: %i[show edit update destroy]
  before_action :prepare_selected_referrer, only: %i[new create edit update]

  def index
    redirect_to dashboard_path
  end

  def show
    @appointments = @customer.appointments.order(starts_at: :desc)
    @contact_calls = @customer.contact_calls.order(called_at: :desc)
    @referred_customers = @customer.referred_customers.order(:last_name, :first_name)
  end

  def new
    @customer = current_user.customers.new(
      relationship_started_on: Date.current,
      referred_by_customer_id: selected_referred_by_customer_id
    )
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

  def referrer_suggestions
    query = params[:q].to_s.strip.downcase
    exclude_customer_id = params[:exclude_customer_id].to_i if params[:exclude_customer_id].present?

    scope = current_user.customers.order(:last_name, :first_name)
    scope = scope.where.not(id: exclude_customer_id) if exclude_customer_id.present?

    if query.present?
      scope = scope.where(
        "LOWER(first_name || ' ' || last_name) LIKE :q OR LOWER(COALESCE(phone, '')) LIKE :q OR LOWER(COALESCE(email, '')) LIKE :q",
        q: "%#{query}%"
      )
    end

    render json: {
      results: scope.limit(20).map do |candidate|
        {
          id: candidate.id,
          text: referrer_label(candidate),
          url: customer_path(candidate)
        }
      end
    }
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:id])
  end

  def customer_params
    permitted = params.require(:customer).permit(
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
      :referred_by_customer_id,
      :personal_summary,
      :active,
      spouses_attributes: %i[id first_name last_name birth_date profession prospects annual_income satisfaction_level _destroy],
      children_attributes: %i[id first_name last_name birth_date profession desires solutions annual_income _destroy],
      customer_expenses_attributes: %i[id expense_type amount description category _destroy],
      banks_attributes: %i[id bank_name referente reason use satisfaction_level deadlines current_account_balance _destroy],
      insurances_attributes: %i[
        id
        reason
        objective
        amount
        investment_frequency
        product_name
        company_name
        subscription_date
        expiry_date
        satisfaction_level
        rendimento
        _destroy
      ],
      properties_attributes: %i[
        id
        purpose
        address
        annual_income
        annual_maintenance_cost
        commercial_value
        _destroy
      ],
      investments_attributes: %i[
        id
        with_me
        active
        product_name
        distributed_by
        subscription_date
        purpose
        advised_by
        amount
        satisfaction_level
        _destroy
      ],
      customer_titles_attributes: %i[id title_type isin initial_capital expires_on rendimento _destroy]
    )

    permitted[:referred_by_customer_id] = normalized_referred_by_customer_id(permitted[:referred_by_customer_id])
    permitted
  end

  def referrer_label(customer)
    [ customer.full_name, customer.phone.presence, customer.email.presence ].compact.join(" - ")
  end

  def selected_referred_by_customer_id
    normalized_referred_by_customer_id(params[:referred_by_customer_id])
  end

  def normalized_referred_by_customer_id(raw_id)
    return nil if raw_id.blank?

    candidate_id = raw_id.to_i
    return nil if @customer&.persisted? && candidate_id == @customer.id

    current_user.customers.where(id: candidate_id).pick(:id)
  end

  def build_nested_associations
    @customer.spouses.build unless @customer.spouses.any?
    @customer.children.build unless @customer.children.any?
    @customer.customer_expenses.build unless @customer.customer_expenses.any?
    @customer.banks.build unless @customer.banks.any?
    @customer.insurances.build unless @customer.insurances.any?
    @customer.properties.build unless @customer.properties.any?
    @customer.investments_with_others.build unless @customer.investments_with_others.any?
    @customer.investments_with_me.build(active: true) unless @customer.investments_with_me.any?
    @customer.customer_titles.build unless @customer.customer_titles.any?
  end

  def prepare_selected_referrer
    @selected_referrer = current_user.customers.find_by(id: selected_referred_by_customer_id_from_request)
  end

  def selected_referred_by_customer_id_from_request
    raw_id = if params[:customer].respond_to?(:[])
      params[:customer][:referred_by_customer_id]
    elsif @customer&.persisted?
      @customer.referred_by_customer_id
    else
      params[:referred_by_customer_id]
    end

    normalized_referred_by_customer_id(raw_id)
  end
end
