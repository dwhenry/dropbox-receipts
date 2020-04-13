require 'dropbox'
require 'open-uri'

class ReceiptSummaryProcessor
  include Sidekiq::Worker
  class GetFailed < StandardError; end

  def perform
    Company.all.each do |company|
      process_company(company)
    end
  end


  def process_company(company)
    summary = nil
    scope = {
      last_receipt_id: Receipt.where(company_id: company.id).maximum(:id),
      last_manual_id: ManualMatch.where(company_id: company.id).maximum(:id),
      company_id: company.id
    }
    return if Summary.find_by(scope)
    return if scope[:last_receipt_id].nil? && scope[:last_receipt_id].nil?

    previous_summary = Summary.where(company_id: company.id).order(for: :desc).first || Summary.new(created_at: DateTime.new(2000, 1, 1), last_receipt_id: 0, last_manual_id: 0)
    summary = Summary.create!(scope.merge(for: Date.today))

    # work out the years we need to generate data for
    receipt_dates = Receipt.where(company_id: company.id).where(id: ((previous_summary.last_receipt_id+1)..(summary.last_receipt_id || 0))).uniq.pluck('purchase_date')
    manual_dates = ManualMatch.where(company_id: company.id).where(id: ((previous_summary.last_receipt_id+1)..(summary.last_receipt_id || 0))).uniq.pluck('date')

    tax_years = (Array(receipt_dates) + Array(manual_dates)).sort.group_by{|d| d < Date.new(d.year, 4, 6) ? d.year : d.year + 1 }.map{|a, b| [a, b.max]}

    client = Dropbox::Client.new(company.user.token)

    tax_years.each do |year, last_date|
      path = '/' + [
        Rails.env.production? ? nil : Rails.env,
        company.primary ? nil : company.name,
        'receipts',
        Date.today.strftime('%Y-%m'),
        'summary',
        [
          Date.today.strftime('%Y%m%d'),
          "#{year-1}-#{year}",
          summary.id,
          'xls'
        ].join('.')
      ].compact.join('/')

      file = get_xls(for: last_date, last_run_at: previous_summary.created_at, company_id: company.id)

      client.upload(path, file)
    end

  rescue
    summary&.delete
    raise
  end

  def get_xls(args)
    ReportsController.render(
      template: 'reports/receipts_summary.xlsx',
      layout: false,
      assigns: args,
    )
  end
end
# ReceiptSummaryProcessor.new.get_xls(company_id: Company.first.id, for: Date.today, last_run_at: Date.new(2020, 1, 1))
# ReportsController.render(template: 'reports/receipts_summary',layout: 'pdf',assigns: {},)
