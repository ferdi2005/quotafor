class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "no-reply@quotafor.local")
  layout "mailer"
end
