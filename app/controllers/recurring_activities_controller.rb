class RecurringActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recurring_activity, only: %i[edit update destroy]

  def index
    @recurring_activities = current_user.recurring_activities.order(:weekday, :starts_at)
  end

  def new
    @recurring_activity = current_user.recurring_activities.build
  end

  def create
    @recurring_activity = current_user.recurring_activities.build(recurring_activity_params)
    if @recurring_activity.save
      redirect_to recurring_activities_path, notice: "Attività ricorrente aggiunta con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @recurring_activity.update(recurring_activity_params)
      redirect_to recurring_activities_path, notice: "Attività ricorrente aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recurring_activity.destroy
    redirect_to recurring_activities_path, notice: "Attività ricorrente eliminata."
  end

  private

  def set_recurring_activity
    @recurring_activity = current_user.recurring_activities.find(params[:id])
  end

  def recurring_activity_params
    params.require(:recurring_activity).permit(:topic, :periodicity, :weekday, :starts_at, :ends_at, :location, :notes, :active)
  end
end
