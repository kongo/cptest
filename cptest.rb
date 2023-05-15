require 'net/http'
require 'json'

def parse_args(args)
  {
    correct: true,
    amount: args[0],
    from_currency: args[1],
    to_currency: args[2]
  }
end

def get_conversion_rate(from_currency, to_currency)
  uri = URI("https://open.er-api.com/v6/latest/#{from_currency.upcase}")
  response = Net::HTTP.get(uri)
  response_obj = JSON.parse(response)
  rate = response_obj["rates"][to_currency.upcase]
  rate
end

def convert_currency(args)
  rate = get_conversion_rate(args[:from_currency], args[:to_currency])
  {
    from_amount: args[:amount],
    from_currency: args[:from_currency],
    to_currency: args[:to_currency],
    to_amount: rate.to_f * args[:amount].to_f
  }
end

args = parse_args(ARGV)

if !args[:correct]
  puts args[:error_message]
else
  conversion = convert_currency(args)
  puts "#{conversion[:from_amount]} #{conversion[:from_currency]} = #{conversion[:to_amount]} #{conversion[:to_currency]}"
end
