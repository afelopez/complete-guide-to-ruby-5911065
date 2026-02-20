count = 1

# ternary operation
puts count == 1 ? "#{count} person" : "#{count} people"

# or operator
DEFAULT_LIMIT = 100
limit = nil
max = limit || DEFAULT_LIMIT
puts max

# or equals operator
limit ||= DEFAULT_LIMIT
puts limit

#
limit = DEFAULT_LIMIT unless limit
puts "You are the only person in this chat room." if count == 1
