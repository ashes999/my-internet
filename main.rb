#!/usr/bin/env ruby

require 'rack'
require 'rack-rewrite'

require './app/server'
require './app/crawler'
require './app/dal/queries'
require './app/utils/logger'

Logger.init('service')
Database.create_if_missing

# Check if sites.txt is defined. 
# Put sites.txt into the queue.
if (!File.exist?('sites.txt'))
  # TODO: prompt instead of failing.
  raise 'Please define a sites.txt file with one line per domain to index'
end
domains = File.read('sites.txt').split
domains.each do |d|
  Queries.add_to_queue(d)
end

server = Server.new

crawler = Thread.new {
  # TODO: replace with DTO for data to share
  Crawler.new.run(server)
}

begin
  server.run
  puts 'Waiting for crawler to terminate ...'
rescue => e
  Logger.info("Exception: #{e}")
  raise e
ensure
  crawler.join
end

puts 'Bye!'
