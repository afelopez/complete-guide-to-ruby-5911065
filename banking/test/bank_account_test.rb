# frozen_string_literal: true

require "minitest/autorun"
require "time"

require_relative "../errors"
require_relative "../money"
require_relative "../account"

class BankAccountTest < Minitest::Test
  FakeClock = Struct.new(:now)

  def money(cents) = Banking::Money.new(cents)

  def test_starts_with_initial_balance
    acc = Banking::BankAccount.new(money(10_00))
    assert_equal money(10_00), acc.balance
  end

  def test_rejects_negative_initial_balance
    error = assert_raises(Banking::NegativeInitialBalanceError) do
      Banking::BankAccount.new(money(-1))
    end
    assert_equal(-1, error.initial_balance)
  end

  def test_deposit_returns_transaction_increases_balance_and_records_transaction
    fixed_time = Time.parse("2026-02-16 12:00:00 UTC")
    acc = Banking::BankAccount.new(money(10_00), clock: FakeClock.new(fixed_time))

    tx = acc.deposit(money(5_00))

    assert_equal :deposit, tx.type
    assert_equal money(5_00), tx.amount
    assert_equal money(15_00), tx.balance_after
    assert_equal fixed_time, tx.at

    assert_equal money(15_00), acc.balance
    assert_equal tx, acc.history.first
  end

  def test_withdraw_returns_transaction_decreases_balance_and_records_transaction
    fixed_time = Time.parse("2026-02-16 12:00:00 UTC")
    acc = Banking::BankAccount.new(money(10_00), clock: FakeClock.new(fixed_time))

    tx = acc.withdraw(money(3_00))

    assert_equal :withdraw, tx.type
    assert_equal money(3_00), tx.amount
    assert_equal money(7_00), tx.balance_after
    assert_equal fixed_time, tx.at

    assert_equal money(7_00), acc.balance
    assert_equal tx, acc.history.first
  end

  def test_rejects_non_positive_amounts
    acc = Banking::BankAccount.new(money(10_00))

    assert_raises(Banking::InvalidMoneyError) { acc.deposit(money(0)) }
    assert_raises(Banking::InvalidMoneyError) { acc.withdraw(money(0)) }

    assert_raises(Banking::InvalidMoneyError) { acc.deposit(money(-1)) }
    assert_raises(Banking::InvalidMoneyError) { acc.withdraw(money(-1)) }
  end

  def test_rejects_withdraw_when_insufficient_funds
    acc = Banking::BankAccount.new(money(10_00))

    err = assert_raises(Banking::InsufficientFundsError) { acc.withdraw(money(99_00)) }
    assert_equal 99_00, err.amount
    assert_equal 10_00, err.balance

    assert_equal money(10_00), acc.balance
    assert_equal 0, acc.history.size
  end

  def test_history_is_encapsulated
    acc = Banking::BankAccount.new(money(10_00))
    acc.deposit(money(1_00))

    txs = acc.history
    assert txs.frozen?
    assert_raises(FrozenError) { txs << :hack }

    acc.deposit(money(1_00))
    assert_equal 2, acc.history.size
  end

  def test_statement_lines_formats_transactions
    fixed_time = Time.parse("2026-02-16 12:00:00 UTC")
    acc = Banking::BankAccount.new(money(0), clock: FakeClock.new(fixed_time))

    acc.deposit(money(5_00))

    assert_equal ["2026-02-16T12:00:00Z DEPOSIT 5.00 -> 5.00"], acc.statement_lines
  end
end
