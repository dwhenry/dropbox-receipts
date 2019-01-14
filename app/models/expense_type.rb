class ExpenseType
  def self.all
    @all ||= [
      new(
        name: 'Cost of Sale',
        children: [
          new(name: 'Material', code: 'MAT'),
          new(name: 'Contractors', code: 'CON'),
          new(name: 'Equipment - Hire', code: 'HIR'),
          new(name: 'Equipment - Small Tools', code: 'SMT'),
          new(name: 'Protective Clothing', code: 'PRT'),
        ]
      ),
      new(
        name: 'Staffing Costs',
        children: [
          new(name: 'Wages', code: 'WAG'),
          new(name: 'Dividends / Drawings', code: 'DIV'),
          new(name: 'Training', code: 'TRA'),
          new(name: 'Subscriptions', code: 'SUB'),
        ]
      ),

      new(
        name: 'Travel & Accommodation',
        children: [
          new(name: 'Vehicle Expenses', code: 'VEH'),
          new(name: 'Fuel', code: 'FUE'),
          new(name: 'Travel', code: 'TRV'),
          new(name: 'Accommodation', code: 'ACM'),
        ]
      ),

      new(
        name: 'Office Costs',
        children: [
          new(name: 'Rent', code: 'RNT'),
          new(name: 'Repairs & Maintenance', code: 'REP'),
        ]
      ),

      new(
        name: 'Administration Costs',
        children: [
          new(name: 'Printing / Postage / Stationary', code: 'PPS'),
          new(name: 'Telephone', code: 'TEL'),
          new(name: 'Computer Costs', code: 'PC'),
          new(name: 'Advertising', code: 'ADV'),
        ]
      ),

      new(
        name: 'Professional Fees',
        children: [
          new(name: 'Accounting', code: 'ACC'),
          new(name: 'Legal / Consulting', code: 'LEG'),
          new(name: 'Insurance (Non-Motor)', code: 'INS'),
        ]
      ),

      new(
        name: 'Other',
        children: [
          new(name: 'Bank Charges / Interest / Loans', code: 'BNK'),
          new(name: 'Fixed Asset', code: 'FA'),
          new(name: 'Personal / Non-allowable', code: 'PER'),
          new(name: 'Other / Miscellaneous', code: 'OTH'),
          new(name: 'VAT / SA / CT Payments', code: 'TAX'),
        ]
      ),

      new(
        name: 'Client Expense Code',
        children: [
          new(name: 'Client Additional 1', code: 'ABC'),
          new(name: 'Client Additional 2', code: 'DEF'),
          new(name: 'Client Additional 3', code: 'GHI'),
        ]
      ),
    ]
  end

  def self.lookup(code)
    return nil if code.blank?

    @items ||= all.flat_map(&:children)
    @items.detect { |c| c.code == code }.name
  end

  attr_reader :name, :code, :children

  def initialize(name:, code: nil, children: [])
    @name = name
    @code = code
    @children = children
  end
end
