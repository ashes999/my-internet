#!/usr/bin/env ruby

require 'rack'
require 'rack-rewrite'

require './app/server'
require './app/crawler'
require './app/indexer'
require './app/dal/queries'
require './app/utils/logger'

SITES_DIRECTORY = 'data/sites'

Logger.init('my_internet')
Database.create_if_missing

# Check if sites.txt is defined. 
# Put sites.txt into the queue.

### NOTE: without mapping pages to sites, we don't know what to index!
# We also don't know which links to remap to local files.

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
  # TODO: replace server with DTO for .terminated
  Crawler.new(SITES_DIRECTORY).run(server)
}

indexer = Thread.new {
  # TODO: replace server with DTO for .terminated
  Indexer.new(SITES_DIRECTORY).run(server)
}

begin
  server.run
  puts 'Waiting for crawler and indexer to terminate ...'
rescue => e
  Logger.info("Exception: #{e}")
  raise e
ensure
  crawler.join
  indexer.join
end

puts 'Bye!'
