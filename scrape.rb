require_relative "./sites"
require "fileutils"
require "net/http"
require "uri"
require "ruby-progressbar"

x = 0
sites_per_batch = 20
number_in_batch = 0
progressbar_length = SITES.count > 99 ? SITES.count : 99
progressbar = ProgressBar.create(length: progressbar_length)

SITES.each do |site|
  progressbar.increment
  number_in_batch += 1
  uri = URI.parse(site)
  response = Net::HTTP.get_response(uri)
  if response == Net::HTTPRedirection
    response = Net::HTTP.get_print(fetch(response['location'], limit - 1))
  else
    response = response.body
  end
  File.open("html-#{x}.txt", "a"){ |f| 
	  f.write(response) 
  }

  if number_in_batch == sites_per_batch
    number_in_batch = 0
    x += 1
  end
end

puts "UTF-8 Formatting Files..."
x = 0

files_count = SITES.length / sites_per_batch
files_count.times do |x|
  %x(vim +"set nobomb | set fenc=utf8 | x" html-#{x}.txt)
end

