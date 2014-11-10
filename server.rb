#!/usr/bin/env ruby

require 'rack'
require 'rack-rewrite'

PORT = 9292

include Rack

def handle_search(env)
  query_string = env['QUERY_STRING']
  query = query_string[query_string.index('q=') + 2, query_string.length]
  return "Hello, world! Here are the reuslts for #{query}"
end


app = Builder.new do 
  use Rewrite do
    rewrite '/', '/index.html'
  end
  
  map '/search' do
    run Proc.new { |env| [200, {'Content-Type' => 'text/html'}, handle_search(env)] }
  end
  
  use CommonLogger, STDOUT
  run Directory.new(Dir.pwd)
end

puts "Serving #{Dir.pwd}"

Handler::Thin.run app, :Port => PORT


