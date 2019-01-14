class ReceiptReport
  def initialize(year:, filter_date:, source:)
    @year = year
    @period = Date.new(year, 4, 5)..Date.new(year + 1, 4, 4)
    @filter_date = filter_date
    @source = source
    @all = Filtered.new(filter_date, year, records)
  end

  delegate :by_month, :total, :each, to: :@all

  def self.months
    (-9..3).map { |i| Date::MONTHNAMES[i] }.compact
  end

  def for(filter, order: nil)
    scope = if filter == :missing
      # Filtered.new(@filter_date, records.where(payer: filter))
      Receipt.where('1 = 2')
    elsif Hash === filter
      records.where(filter)
    else
      records.where(payer: filter)
    end

    scope = scope.order(order) if order
    Filtered.new(@filter_date, @year, scope)
  end

  def extract(field:, filter_on: nil)
    records.flat_map do |record|
      filter_on ? record[field].map { |row| row[filter_on] } : record[field]
    end.uniq.sort
  end

  def records
    @source.where(@filter_date => @period)
  end

  def each(&block)
    records.order(@filter_date).each(&block)
  end

  class Filtered
    def initialize(filter_date, year, records)
      @filter_date = filter_date
      @year = year
      @records = records
    end

    def by(field)
      @records.distinct.pluck(field).each do |name|
        yield(name, Filtered.new(@filter_date, @year, @records.where(field => name)))
      end
    end

    def each(&block)
      @records.order(@filter_date).each(&block)
    end

    def total(field: :amount, filter_on: nil, filter_value: nil, sum_value: nil)
      return @records.sum(field)&.abs unless filter_on
      @records.sum do |record|
        record[field].sum do |row|
          row[filter_on] == filter_value ? row[sum_value].to_f : 0
        end
      end
    end

    def by_month(field: :amount, filter_on: nil, filter_value: nil, sum_value: nil)
      months = (4..12).map { |a| "#{@year}-#{a < 10 ? "0#{a}" : a}" } + (1..3).map { |a| "#{@year + 1}-0#{a}" }
      if filter_on
        months.map do |month|
          data = @records.where("to_char(#{@filter_date} - 5, 'yyyy-mm') = ?", month)
          data.sum do |record|
            record[field].sum do |row|
              row[filter_on] == filter_value ? row[sum_value].to_f : 0
            end
          end
        end
      else
        data = @records.group("to_char(#{@filter_date} - 5, 'yyyy-mm')").reorder('').sum(field)
        months.map { |month| data[month]&.abs}
      end
    end
  end
end
