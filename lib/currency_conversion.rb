class CurrencyConversion
  class RuntimeError < StandardError; end

  attr_reader :from_amount, :from_currency, :to_currency, :to_amount

  def initialize(from_currency:, to_currency:, amount:, api:)
    @from_currency = from_currency.to_s.upcase
    @to_currency   = to_currency.to_s.upcase
    @from_amount   = amount
    @api           = api

    validate_input

    begin
      calculate_amount
    rescue api.class::RuntimeError => e
      raise RuntimeError.new(e.message)
    end

    self
  end

  private

  def validate_input
    if !(
        @api.valid_currency?(@from_currency) &&
        @api.valid_currency?(@to_currency)
    )
      raise RuntimeError.new("Currencies should be within designated list")
    end
  end

  def calculate_amount
    rate = @api.get_conversion_rate(@from_currency, @to_currency)

    if (rate.positive?)
      @to_amount = (rate * @from_amount).round(2)
    else
      raise RuntimeError.new("Something went wrong within external service")
    end
  end
end
