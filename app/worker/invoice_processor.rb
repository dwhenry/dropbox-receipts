require 'dropbox_sdk'

class InvoiceProcessor
  include Sidekiq::Worker
  class GetFailed < StandardError; end

  def perform(invoice_id, path_to_pdf)
    invoice = Invoice.find(invoice_id)

    path = invoice.build_path
    client = DropboxClient.new(invoice.user.token)

    unless invoice.generated_at
      invoice.update!(generated_at: Time.now)
      begin
        pdf = get_pdf(path_to_pdf)

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

  def get_pdf(path_to_pdf)
    uri = URI.parse(path_to_pdf)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      response = http.request request
      raise GetFailed unless (200..399).cover?(response.code.to_i)
      response.body
    end
  end
end
