class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice, attachment)
    attachments[invoice.filename] = attachment
    mail(
      to: invoice.recipients.split(/\r?\n/),
      subject: "Invoice for #{invoice.company.name} [#{invoice.company.user.name}] (#{invoice.tax_date.strftime('%d-%b-%Y')})",
      body: ''
    )
  end
end
