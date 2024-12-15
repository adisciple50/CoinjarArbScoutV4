class Currency
  attr_reader :id_or_iso_code, :fiat,:amount
  def initialize(currency_id_or_iso,stake)
    @id_or_iso_code = currency_id_or_iso.to_s.upcase
    @amount = stake || 0.0
  end
  def is_fiat?
    ["AUD","GBP","USD","EURO"].include? @id_or_iso_code
  end
  def is_cryptocurrency?
    is_fiat?
  end
end