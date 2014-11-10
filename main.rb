#!/usr/bin/env ruby

require 'rack'
require 'rack-rewrite'

require './app/server'
require './app/search'

Server.new.run
