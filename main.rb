#!/usr/bin/env ruby

require 'rack'
require 'rack-rewrite'

require './app/server'
require './app/crawler'

# Check if sites.txt is defined. Prompt if not.
# Put sites.txt into the queue.

server = Server.new

crawler = Thread.new {
  # TODO: replace with DTO for data to share
  Crawler.new.run(server)
}

server.run

puts 'Waiting for crawler to terminate ...'
crawler.join

puts 'Bye!'
