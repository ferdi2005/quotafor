class CustomerObjectivesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer
  before_action :set_objective, only: %i[edit update destroy]

  def new
    @objective = @customer.customer_objectives.new(active: true)
  end

  def create
    @objective = @customer.customer_objectives.new(objective_params)
    if @objective.save
      redirect_to customer_path(@customer), notice: "Obiettivo aggiunto con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @objective.update(objective_params)
      redirect_to customer_path(@customer), notice: "Obiettivo aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @objective.destroy
    redirect_to customer_path(@customer), notice: "Obiettivo eliminato."
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:customer_id])
  end

  def set_objective
    @objective = @customer.customer_objectives.find(params[:id])
  end

  def objective_params
    params.require(:customer_objective).permit(:title, :description, :resources, :active)
  end
end
