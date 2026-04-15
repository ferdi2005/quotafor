class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "noreply@quotaformazione.it")
  layout "mailer"
end
