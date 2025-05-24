class Transaction
  TRANSACTION_TYPES = [ "deposit", "withdraw" ]

  attr_reader :transaction_type, :amount, :timestamp, :errors
  def initialize(transaction_type, amount, timestamp)
    @transaction_type = transaction_type
    @amount = amount
    @timestamp = timestamp
    @errors = []
  end

  def valid?
    # Adds errors to errors attr
    # returns true/false based on errors
    @errors << transaction_type_error unless valid_transaction?
    @errors << amount_error unless valid_amount?
    @errors << timestamp_error unless valid_timestamp?

    errors.empty?
  end

  def effective_amount
    # amount that will affect balance
    # negative for withdrawl & positive for deposit
    deposit? ? amount : (amount * -1)
  end

  def deposit?
    transaction_type == "deposit"
  end

  private


  def valid_timestamp?
    # very basic timestamp validation
    # any date as string will convert to time class otherwise nil
    # returns bool to assess if .to_time returns a value

    timestamp.is_a?(Time) || !!timestamp&.to_time
  end

  def timestamp_error
    "Timestamp is an invalid time format YYYY-MM-DD HH:MM:SS"
  end

  def valid_transaction?
    TRANSACTION_TYPES.include? transaction_type
  end

  def valid_amount?
     amount.to_i > 0
  end

  def amount_error
    "Amount must be a non negative numeric value."
  end

  def transaction_type_error
    "#{transaction_type} is not a valid transaction type, 'transaction_type' must be one of: #{TRANSACTION_TYPES.join(", ")}."
  end
end
