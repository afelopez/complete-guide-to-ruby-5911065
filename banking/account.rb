# frozen_string_literal: true
require "time"

module Banking
  Transaction = Data.define(:type, :amount, :balance_after, :at) do
    def self.deposit(amount:, balance_after:, at:)
      new(type: :deposit, amount: amount, balance_after: balance_after, at: at)
    end

    def self.withdraw(amount:, balance_after:, at:)
      new(type: :withdraw, amount: amount, balance_after: balance_after, at: at)
    end
  end

  class BankAccount
    def initialize(initial_balance = 0, clock: Time)
      raise NegativeInitialBalanceError.new(initial_balance) if initial_balance < 0

      @balance = initial_balance
      @transactions = []
      @clock = clock
    end

    def balance
      @balance
    end

    # ✅ API pública: vista segura del historial (no estructura mutable)
    def history
      transactions_snapshot
    end

    # ✅ API pública: extracto ya formateado
    def statement_lines
      transactions_snapshot.map do |t|
        "#{t.at.iso8601} #{t.type.upcase} #{t.amount} -> #{t.balance_after}"
      end
    end

    def deposit(amount)
      validate_amount!(amount)

      @balance += amount
      tx = Transaction.deposit(amount: amount, balance_after: @balance, at: @clock.now)
      record(tx)

      tx
    end

    def withdraw(amount)
      validate_amount!(amount)
      raise InsufficientFundsError.new(amount, @balance) if amount > @balance

      @balance -= amount
      tx = Transaction.withdraw(amount: amount, balance_after: @balance, at: @clock.now)
      record(tx)

      tx
    end

    private

    # 🔒 Nadie fuera debe tocar esto
    def transactions
      @transactions
    end

    # ✅ Vista segura (copia congelada)
    def transactions_snapshot
      transactions.dup.freeze
    end

    def validate_amount!(amount)
      raise InvalidAmountError.new(amount, "Amount must be an Integer") unless amount.is_a?(Integer)
      raise InvalidAmountError.new(amount) if amount <= 0
    end

    def record(transaction)
      transactions << transaction
    end
  end
end
