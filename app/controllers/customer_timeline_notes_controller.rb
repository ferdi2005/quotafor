class CustomerTimelineNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer

  def new
    @timeline_note = @customer.customer_timeline_notes.new(user: current_user, happened_at: Time.current)
  end

  def create
    @timeline_note = @customer.customer_timeline_notes.new(timeline_note_params.merge(user: current_user))
    if @timeline_note.save
      redirect_to customer_path(@customer), notice: "Nota aggiunta alla timeline."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @timeline_note = @customer.customer_timeline_notes.find(params[:id])
    @timeline_note.destroy
    redirect_to customer_path(@customer), notice: "Nota eliminata."
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:customer_id])
  end

  def timeline_note_params
    params.require(:customer_timeline_note).permit(:happened_at, :category, :content)
  end
end
