require 'net/http'
require 'json'
require './lib/currency_conversion'
require './lib/open_er_api'

currency_api = OpenErApi.new

begin
  conversion = CurrencyConversion.new(
    amount:        ARGV[0].to_f,
    from_currency: ARGV[1],
    to_currency:   ARGV[2],
    api:           currency_api
  )
  puts "#{conversion.from_amount} #{conversion.from_currency} = #{conversion.to_amount} #{conversion.to_currency}"
rescue CurrencyConversion::RuntimeError => e
  puts "Error: #{e.message}"
end
