require 'dropbox'
require 'open-uri'

class DividendProcessor
  include Sidekiq::Worker
  class GetFailed < StandardError; end

  def perform(dividend_id)
    dividend = Dividend.find(dividend_id)

    path = dividend.build_path
    client = Dropbox::Client.new(dividend.company.user.token)

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

    unless dividend.sent_at || dividend.recipients.blank?
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
      template: 'dividends/preview',
      layout: 'pdf',
      assigns: {
        dividend: dividend,
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
