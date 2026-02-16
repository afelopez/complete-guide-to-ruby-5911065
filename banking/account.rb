# frozen_string_literal: true
require "time"
require_relative "money"

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
    def initialize(initial_balance = Money.zero, clock: Time)
      @clock = clock
      @transactions = []

      initial = normalize_money(initial_balance)
      raise NegativeInitialBalanceError.new(initial.cents) if initial.cents < 0

      @balance = initial
    end

    def balance
      @balance
    end

    def history
      transactions_snapshot
    end

    def statement_lines
      transactions_snapshot.map do |t|
        "#{t.at.iso8601} #{t.type.upcase} #{t.amount} -> #{t.balance_after}"
      end
    end

    def deposit(amount)
      amount = normalize_money(amount)
      validate_positive_money!(amount)

      @balance = @balance + amount
      tx = Transaction.deposit(amount: amount, balance_after: @balance, at: @clock.now)
      record(tx)
      tx
    end

    def withdraw(amount)
      amount = normalize_money(amount)
      validate_positive_money!(amount)

      raise InsufficientFundsError.new(amount.cents, @balance.cents) if amount > @balance

      @balance = @balance - amount
      tx = Transaction.withdraw(amount: amount, balance_after: @balance, at: @clock.now)
      record(tx)
      tx
    end

    private

    def transactions
      @transactions
    end

    def transactions_snapshot
      transactions.dup.freeze
    end

    def record(tx)
      transactions << tx
    end

    def normalize_money(value)
      return value if value.is_a?(Money)
      Money.new(value) # permite pasar Integer en centavos si quieres
    rescue InvalidMoneyError => e
      raise e
    rescue StandardError
      raise InvalidMoneyError.new(value, "Expected Money or Integer cents")
    end

    def validate_positive_money!(money)
      raise InvalidMoneyError.new(money, "Amount must be positive") unless money.positive?
    end
  end
end
