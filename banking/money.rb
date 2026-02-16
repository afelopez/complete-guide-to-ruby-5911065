# frozen_string_literal: true

module Banking
  class Money
    include Comparable

    attr_reader :cents

    def initialize(cents)
      raise InvalidMoneyError.new(cents, "Money must be an Integer (cents)") unless cents.is_a?(Integer)
      @cents = cents
      freeze
    end

    def self.zero = new(0)

    def positive?
      cents.positive?
    end

    def <=>(other)
      other = coerce_money(other)
      cents <=> other.cents
    end

    def +(other)
      other = coerce_money(other)
      self.class.new(cents + other.cents)
    end

    def -(other)
      other = coerce_money(other)
      self.class.new(cents - other.cents)
    end

    def to_s
      # Formato simple: 12345 => "123.45"
      sign = cents.negative? ? "-" : ""
      abs = cents.abs
      "#{sign}#{abs / 100}.#{(abs % 100).to_s.rjust(2, "0")}"
    end

    private

    def coerce_money(value)
      return value if value.is_a?(self.class)
      raise InvalidMoneyError.new(value, "Expected Money, got: #{value.class}")
    end
  end
end
