#!/usr/bin/env ruby
class Main
  require 'rack'
  require 'rack-rewrite'
  require'filewatcher'

  require './app/server'
  require './app/crawler'
  require './app/indexer'
  require './app/dal/queries'
  require './app/utils/logger'

  SITES_DIRECTORY = 'data/sites'
  SITES_FILE = 'sites.txt'
    
  def run
    Logger.init('/tmp/my_internet')
    Database.create_if_missing

    ### NOTE: without mapping pages to sites, we don't know what to index!
    # We also don't know which links to remap to local files.
    
    if (File.exist?(SITES_FILE))
      queue_sites_file
    else
      raise "Please define a #{SITES_FILE} file with one line per domain to index"
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
    
    watcher = Thread.new {
      FileWatcher.new([SITES_FILE]).watch do |f|
        num = queue_sites_file
        puts "Reloaded #{SITES_FILE} with #{num} sites"
        Logger.info('Reloaded sites file')
      end
    }
    
    begin
      server.run
      puts 'Waiting for crawler and indexer to terminate ...'
    rescue => e
      Logger.info("Exception: #{e}")
      Logger.info(e.backtrace)
    ensure
      crawler.join
      indexer.join
    end

    puts 'Bye!'
  end
  
  def queue_sites_file
    domains = File.read(SITES_FILE).split
    domains.each do |d|
      Queries.add_to_queue(d)
    end
    
    return domains.length
  end
end

Main.new.run
