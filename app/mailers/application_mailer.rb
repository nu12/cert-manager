class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{Rails.configuration.action_mailer.default_url_options[:host]}"
  layout "mailer"
end
