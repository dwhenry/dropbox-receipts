class BankAccountMailer < ApplicationMailer
  def business_statement_email(user, name, year, data)
    attachments["BankStmt - #{name} - #{year-1}/#{year}.csv"] = data
    mail(
      to: user.email,
      subject: "BankStmt - #{name} - #{year-1}/#{year}",
      body: ''
    )
  end
end
