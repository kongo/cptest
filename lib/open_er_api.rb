require 'net/http'
require 'json'

class OpenErApi
  class RuntimeError < StandardError; end

  AVAILABLE_CURRENCIES = [
    "USD", "AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", "BGN",
    "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BTN", "BWP", "BYN", "BZD", "CAD", "CDF", "CHF", "CLP",
    "CNY", "COP", "CRC", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ERN", "ETB", "EUR", "FJD",
    "FKP", "FOK", "GBP", "GEL", "GGP", "GHS", "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG",
    "HUF", "IDR", "ILS", "IMP", "INR", "IQD", "IRR", "ISK", "JEP", "JMD", "JOD", "JPY", "KES", "KGS", "KHR",
    "KID", "KMF", "KRW", "KWD", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD", "LSL", "LYD", "MAD", "MDL", "MGA",
    "MKD", "MMK", "MNT", "MOP", "MRU", "MUR", "MVR", "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NIO", "NOK",
    "NPR", "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON", "RSD", "RUB", "RWF",
    "SAR", "SBD", "SCR", "SDG", "SEK", "SGD", "SHP", "SLE", "SLL", "SOS", "SRD", "SSP", "STN", "SYP", "SZL",
    "THB", "TJS", "TMT", "TND", "TOP", "TRY", "TTD", "TVD", "TWD", "TZS", "UAH", "UGX", "UYU", "UZS", "VES",
    "VND", "VUV", "WST", "XAF", "XCD", "XDR", "XOF", "XPF", "YER", "ZAR", "ZMW", "ZWL"
  ]

  SERVICE_ENDPOINT = "https://open.er-api.com/v6"
  
  def valid_currency?(currency)
    AVAILABLE_CURRENCIES.include? currency.upcase
  end

  def get_conversion_rate(from_currency, to_currency)
    response     = get_service_response(from_currency.upcase)
    response_obj = parse_response(response)
    get_rate_from_parsed_response(response_obj, to_currency.upcase)
  end

  private

  def get_service_response(from_currency)
    uri = URI("#{SERVICE_ENDPOINT}/latest/#{from_currency}")
    Net::HTTP.get(uri)
  rescue SocketError
    raise RuntimeError.new("Service unavailable")
  end

  def parse_response(response)
    JSON.parse(response)
  rescue JSON::ParserError
    raise RuntimeError.new("External service error (wrong JSON response)")
  end

  def get_rate_from_parsed_response(response_obj, to_currency)
    if (response_obj["rates"].nil? || response_obj["rates"][to_currency].nil?)
      raise RuntimeError.new("External service error (malformed response)")
    end
    response_obj["rates"][to_currency].to_f
  end
end
