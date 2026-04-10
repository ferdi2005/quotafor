class ContactCallsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer
  before_action :set_contact_call, only: %i[edit update destroy]

  def new
    @contact_call = @customer.contact_calls.new(user: current_user, called_at: Time.current, call_type: :first_visit)
  end

  def create
    @contact_call = @customer.contact_calls.new(contact_call_params.merge(user: current_user))
    if @contact_call.save
      redirect_to customer_path(@customer), notice: "Telefonata registrata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contact_call.update(contact_call_params)
      redirect_to customer_path(@customer), notice: "Telefonata aggiornata."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact_call.destroy
    redirect_to customer_path(@customer), notice: "Telefonata eliminata."
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:customer_id])
  end

  def set_contact_call
    @contact_call = @customer.contact_calls.find(params[:id])
  end

  def contact_call_params
    params.require(:contact_call).permit(:called_at, :scheduled_for, :notes, :call_type)
  end
end
