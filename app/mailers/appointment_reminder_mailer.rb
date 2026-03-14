class AppointmentReminderMailer < ApplicationMailer
  def day_before(user, event)
    @user = user
    @event = event
    @customer = event.customer

    mail(
      to: @user.email,
      subject: "Promemoria appuntamento di domani"
    )
  end
end
