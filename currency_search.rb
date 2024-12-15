class CurrencySearch
  def search(currency_objects_array,required_currency_iso_code)
    currency_objects_array.select {|currency| currency.id_or_iso_code == required_currency_iso_code}
  end
end
