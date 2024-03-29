require 'dropbox'
require 'open-uri'

class ManualProcessor
  include Sidekiq::Worker
  class GetFailed < StandardError; end

  def perform(manual_id)
    manual = ManualMatch.find(manual_id)

    path = manual.build_path
    client = MyDropboxClient.new(manual.company.user.token)

    unless manual.generated_at
      manual.update!(generated_at: Time.now)
      begin
        pdf = get_pdf(manual)

        client.upload(path, pdf)
      rescue
        manual.update!(generated_at: nil)
        raise
      end
    end
  end

  def get_pdf(manual)
    html = ManualMatchesController.render(
      template: 'manual_matches/preview',
      layout: 'pdf',
      assigns: {
        manual: manual
      },
    )

    WickedPdf.new.pdf_from_string(
      html,
      pdf: manual.filename,
      zoom: 0.75
    )
  end
end
