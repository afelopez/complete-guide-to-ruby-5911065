# Blanket Patterns Solution 4
# Similar to Solution 3, but fancy
# Changes characters at halfway point
# Reverses direction after halfway point

pattern = "|/|="
lines = 16
width = 16
halfway = (lines / 2.0).floor

pattern_array = (pattern*width).split('')
reversed_pattern = pattern_array.map{|p| p == '/' ? '\\' : p }.reverse

(1...lines-1).each do  |n|
  first = pattern_array.shift
  last = reversed_pattern.pop
  pattern_array << first
  reversed_pattern.unshift(last)
  if n < halfway
    puts pattern_array.join + reversed_pattern.join
  else
    puts reversed_pattern.join + pattern_array.join 
  end
end
