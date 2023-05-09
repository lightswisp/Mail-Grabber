#!/usr/bin/ruby
require "spidr"
require 'optparse'
require 'set'
require 'colorize'

DOMAINS = File.read("domains").chomp.split("|")
ARGV << '-h' if ARGV.empty?

options = {}
OptionParser.new do |opts|
  opts.banner = "Mail grabber\n".bold + "Usage: main.rb [options]"

  opts.on("-v", "--verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  
  opts.on("-h", "--help", "Prints this help") do
     puts opts
     exit
  end

  opts.on("-uURL", "--urlURL", "URL to sprider/crawl, example: https://example.com") do |u|
	options[:url] = u
  end
  
end.parse!

if !options[:url]
	puts "Please include a url using -u or --url".red
	exit
end

emails = Set.new
start_time = Time.now
puts "Started at #{start_time}"

Spidr.site("#{options[:url]}") do |spider|
  spider.every_page do |page|

      page.body.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).each {|email|
        if email
		  if DOMAINS.include?(email.split(".").last)
		  	puts "[+] Found #{email} at #{page.url}".green if options[:verbose] && !emails.include?(email)
			emails << email 
		  end
		end
      }
      
  end
end

puts "Total execution time: #{Time.now - start_time}s"

if emails.size > 0
	File.write('results.txt', emails.join("\n"))
	puts "All results were written to results.txt"
else
	puts "No results"
end




