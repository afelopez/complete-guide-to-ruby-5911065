module Banking
  class Error < StandardError; end

  class InvalidAmountError < Error
    attr_reader :amount

    def initialize(amount, message = nil)
      @amount = amount
      super(message || "Amount must be positive. Got: #{amount.inspect}")
    end
  end

  class NegativeInitialBalanceError < Error
    attr_reader :initial_balance

    def initialize(initial_balance, message = nil)
      @initial_balance = initial_balance
      super(message || "Initial balance cannot be negative. Got: #{initial_balance.inspect}")
    end
  end

  class InsufficientFundsError < Error
    attr_reader :amount, :balance

    def initialize(amount, balance, message = nil)
      @amount = amount
      @balance = balance
      super(message || "Insufficient funds: tried to withdraw #{amount}, balance is #{balance}")
    end
  end
end
