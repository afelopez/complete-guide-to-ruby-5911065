# frozen_string_literal: true

require "minitest/autorun"
require "time"

require_relative "../errors"
require_relative "../account"

class BankAccountTest < Minitest::Test
  FakeClock = Struct.new(:now)

  def test_starts_with_initial_balance
    acc = Banking::BankAccount.new(100)
    assert_equal 100, acc.balance
  end

  def test_rejects_negative_initial_balance
    error = assert_raises(Banking::NegativeInitialBalanceError) do
      Banking::BankAccount.new(-1)
    end
    assert_equal(-1, error.initial_balance)
  end

  def test_deposit_increases_balance_and_records_transaction
    fixed_time = Time.parse("2026-02-16 12:00:00 UTC")
    acc = Banking::BankAccount.new(10, clock: FakeClock.new(fixed_time))

    tx = acc.deposit(5)

    assert_equal :deposit, tx.type
    assert_equal 5, tx.amount
    assert_equal 15, tx.balance_after
    assert_equal fixed_time, tx.at

    assert_equal 15, acc.balance
    txs = acc.history
    assert_equal 1, txs.size

    t = txs.first
    assert_equal :deposit, t.type
    assert_equal 5, t.amount
    assert_equal 15, t.balance_after
    assert_equal fixed_time, t.at
  end

  def test_withdraw_decreases_balance_and_records_transaction
    fixed_time = Time.parse("2026-02-16 12:00:00 UTC")
    acc = Banking::BankAccount.new(10, clock: FakeClock.new(fixed_time))

    tx = acc.withdraw(3)

    assert_equal :withdraw, tx.type
    assert_equal 3, tx.amount
    assert_equal 7, tx.balance_after
    assert_equal fixed_time, tx.at
    
    assert_equal 7, acc.balance
    txs = acc.history
    assert_equal 1, txs.size

    t = txs.first
    assert_equal :withdraw, t.type
    assert_equal 3, t.amount
    assert_equal 7, t.balance_after
    assert_equal fixed_time, t.at
  end

  def test_rejects_non_positive_amounts
    acc = Banking::BankAccount.new(10)

    [0, -1].each do |bad|
      err = assert_raises(Banking::InvalidAmountError) { acc.deposit(bad) }
      assert_equal bad, err.amount

      err = assert_raises(Banking::InvalidAmountError) { acc.withdraw(bad) }
      assert_equal bad, err.amount
    end
  end

  def test_rejects_non_integer_amounts
    acc = Banking::BankAccount.new(10)

    err = assert_raises(Banking::InvalidAmountError) { acc.deposit(1.5) }
    assert_match(/Integer/i, err.message)

    err = assert_raises(Banking::InvalidAmountError) { acc.withdraw("2") }
    assert_match(/Integer/i, err.message)
  end

  def test_rejects_withdraw_when_insufficient_funds
    acc = Banking::BankAccount.new(10)

    err = assert_raises(Banking::InsufficientFundsError) { acc.withdraw(99) }
    assert_equal 99, err.amount
    assert_equal 10, err.balance

    # Invariante: balance no cambia y no se registra transacción
    assert_equal 10, acc.balance
    assert_equal 0, acc.history.size
  end

  def test_history_is_encapsulated
    acc = Banking::BankAccount.new(10)
    acc.deposit(1)

    txs = acc.history

    # Vista inmutable
    assert txs.frozen?
    assert_raises(FrozenError) { txs << :hack }

    # Internamente sí crece con nuevas operaciones
    acc.deposit(1)
    assert_equal 2, acc.history.size
  end

  def test_statement_lines_formats_transactions
    fixed_time = Time.parse("2026-02-16 12:00:00 UTC")
    acc = Banking::BankAccount.new(0, clock: FakeClock.new(fixed_time))

    acc.deposit(5)

    assert_equal ["2026-02-16T12:00:00Z DEPOSIT 5 -> 5"], acc.statement_lines
  end
end
