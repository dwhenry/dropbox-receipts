class DividendMailer < ApplicationMailer
  def dividend_email(dividend, attachment)
    attachments[dividend.filename] = attachment
    mail(
      to: dividend.recipients.split(/\r?\n/),
      subject: "Dividend for #{dividend.company_name} (#{dividend.dividend_date.strftime('%d-%b-%Y')})",
      body: ''
    )
  end
end
