require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

puts "Event Manager initialized!"

file_path = "/home/adnan/ruby/projects/event_manager/Event-Manager/event_attendees.csv"
if File.exist?(file_path)
  contents = CSV.open(
    file_path, 
    headers: true,
    header_converters: :symbol
    )
else 
  puts "File does not exist"
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials

    legislator_names = legislators.map(&:name)

    legislators_string = legislator_names.join(", ")
  rescue => exception 
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

  puts "#{name} #{zipcode} #{legislators_string}"
end
