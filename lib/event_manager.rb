require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phones(phone)
  phone_copy = phone.delete("^0-9")
  if phone_copy.length == 10 
    return phone_copy
  elsif phone_copy.length == 11 && phone_copy[0] == '1'
    return phone_copy[1...phone_copy.length]
  end
  "XXXXXXXXXX"
end

def find_peak_hour(times)
  occurrences = Hash.new(0) 
  times.each{|time| occurrences[time] += 1}
  result = occurrences.sort_by{|key,value| value}[-1][0]
  puts "The peak hour is #{result} O' clock"
end

def find_peak_day(dates)
  reference = {0 => "Sunday",
    1 => "Monday", 
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday"}
  days = dates.map{|date| date.wday}
  occurrences = Hash.new(0)
  days.each{|day| occurrences[day] += 1}
  result = occurrences.sort_by{|key,value| value}[-1][0]
  puts "Most people registered on #{reference[result]}."
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

times = [] #stores the time an attendee was registered.
dates = []  #stores the dates an attendee was registered.

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  home_phones = clean_phones(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)

  times.push(row[:regdate].split[1]) #fetches the hour
  dates.push(row[:regdate].split[0]) #fetches the day

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

find_peak_hour(times.map{|hour| hour.split(":")[0].to_i})
find_peak_day(dates.map{|date| Date.strptime(date, "%m/%d/%y")})