#!/usr/bin/env ruby

require 'date'

days = Date::DAYNAMES
puts days
def ordinalize(number)
	num_string = number.to_s
  last_two_digits = num_string[-2,2]
	last_digit = num_string[-1,1]
	case
	when ["11","12","13"].include?(last_two_digits)
	  ending = "th"
	when last_digit == "1"
		ending = "st"
	when last_digit == "2"
	  ending = "nd"
	when last_digit == "3"
	  ending = "rd"
	else
	  ending = "th"
	end
	num_string + ending
end

puts "----------------------"
puts "| Birthdate Analysis |"
puts "----------------------"

puts "What year were you born?"
print "> "
year = gets.chomp

puts "What number month were you born?"
print "> "
month = gets.chomp

puts "What day of the month were you born?"
print "> "
day = gets.chomp

puts

birthdate = Date.new(year.to_i, month.to_i, day.to_i)

puts "-" * 20

wday = birthdate.wday
day_name = days[wday]
puts "You were born on a #{day_name}"

puts "It was the #{ordinalize(birthdate.cweek)} week of the year."

puts "It was the #{ordinalize(birthdate.yday)} day of the year."

if birthdate.leap?
  puts "You were born in a leap year."
else
  puts "You were not born in a leap year."
end

puts "-" * 20
puts
