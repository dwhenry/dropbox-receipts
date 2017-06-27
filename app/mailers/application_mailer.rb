class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@dropbox-accounts.herokuapp.com'
  layout 'mailer'
end
