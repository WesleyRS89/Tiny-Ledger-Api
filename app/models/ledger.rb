class Ledger
    include Singleton # Allows for one instance of Ledger for entire app
    attr_reader :balance, :transactions
    def initialize
        @transactions = []
        @balance = 0
    end

  def create_transaction(amount, transaction_type, created_at = nil)
    created_at ||= Time.now # default timestamp is now
    transaction = Transaction.new(
      transaction_type,
      amount,
      created_at
    )

    if transaction.valid?
      @transactions << transaction
      @balance += transaction.effective_amount
      {
        success: true,
        transaction_amount: formatted_amount(transaction.amount),
        transaction_type: transaction.transaction_type,
        current_balance: formatted_amount(@balance)
      }
    else
      {
        success: false,
        errors: transaction.errors.join(", ")
      }
    end
  end


  def formatted_balance
    formatted_amount(@balance)
  end

  def transaction_history
    # returns array of objects with transaction data
    @transactions.map do |transaction|
      {
        transaction_amount: formatted_amount(transaction.amount),
        transaction_type: transaction.transaction_type,
        transaction_date: transaction.timestamp
      }
    end
  end

  def formatted_amount(amount)
    "%.2f" % amount  # i.e. 00.00
  end
end
