count = 1

# boolean form
case
when count == 0
  puts "nobody"
when count == 1
  puts "1 person"
when (2..5).include?(count)
  puts "several people"
else
  puts "many people"
end


# comparation form
case count
when 0
  puts "nobody"
when 1
  puts "1 person"
when 2..5
  puts "several people"
else
  puts "many people"
end
