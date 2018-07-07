require 'dropbox'
require 'open-uri'

class DividendProcessor
  include Sidekiq::Worker
  class GetFailed < StandardError; end

  def perform(dividend_id)
    dividend = Divdend.find(dividend_id)

    path = dividend.build_path
    client = Dropbox::Client.new(dividend.user.token)

    unless dividend.generated_at
      dividend.update!(generated_at: Time.now)
      begin
        pdf = get_pdf(dividend)

        client.upload(path, pdf)
      rescue
        dividend.update!(generated_at: nil)
        raise
      end
    end

    unless dividend.sent_at && dividend.recipients.present?
      dividend.update!(sent_at: Time.now)
      begin
        pdf ||= client.download(path)

        DividendMailer.dividend_email(dividend, pdf).deliver
      rescue
        dividend.update!(sent_at: nil)
        raise
      end
    end
  end

  def get_pdf(dividend)
    html = DividendsController.render(
      template: 'dividend/preview',
      layout: 'pdf',
      assigns: {
        invoice: dividend,
        skip_overlay: true,
      },
    )

    WickedPdf.new.pdf_from_string(
      html,
      pdf: "dividend_#{dividend.dividend_date.strftime('%Y%m%d')}",
      zoom: 0.75
    )
  end
end
