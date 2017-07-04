require 'dropbox_sdk'
require 'open-uri'

class InvoiceProcessor
  include Sidekiq::Worker
  class GetFailed < StandardError; end

  def perform(invoice_id, _ = nil)
    invoice = Invoice.find(invoice_id)

    path = invoice.build_path
    client = DropboxClient.new(invoice.user.token)

    unless invoice.generated_at
      invoice.update!(generated_at: Time.now)
      begin
        pdf = get_pdf(invoice)

        client.put_file(path, pdf)
      rescue
        invoice.update!(generated_at: nil)
        raise
      end
    end

    unless invoice.sent_at
      invoice.update!(sent_at: Time.now)
      begin
        pdf ||= client.get_file(path)

        InvoiceMailer.invoice_email(invoice, pdf).deliver
      rescue
        invoice.update!(sent_at: nil)
        raise
      end
    end
  end

  def get_pdf(invoice)
    html = InvoicesController.render(
      template: 'invoices/preview',
      layout: 'pdf',
      assigns: {
        invoice: invoice,
        skip_overlay: true,
      },
    )

    WickedPdf.new.pdf_from_string(
      html,
      pdf: "invoice_#{invoice.tax_date.strftime('%Y%m%d')}",
    )
  end
end
