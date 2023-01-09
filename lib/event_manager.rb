require 'csv'

puts "Event Manager initialized!"

file_path = "/home/adnan/ruby/projects/event_manager/event_attendees.csv"
if File.exist?(file_path)
  contents = CSV.open(
    file_path, 
    headers: true,
    header_converters: :symbol
    )
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

contents.each do|row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])
  
  puts "#{name} #{zipcode}"
end
