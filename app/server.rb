class Server

  PORT = 9292
  include Rack
  require './app/crawler'
  
  attr_reader :exit
  
  def run
    @exit = false
    app = Builder.new do 
      use Rewrite do
        rewrite '/', '/index.html'
      end
      
      map '/search' do
        run Proc.new { |env| [200, {'Content-Type' => 'text/html'}, Search.new.handle_search(env)] }
      end
      
      use CommonLogger, STDOUT
      # Handles static content
      run Directory.new(Dir.pwd)
    end
    
    crawler = Thread.new {
      # TODO: replace with DTO for data to share
      Crawler.new.run(self)
    }

    Database.create_if_missing()
    puts "Serving static content from #{Dir.pwd}"

    Handler::Thin.run app, :Port => PORT
    
    @exit = true
    puts 'Waiting for crawler to terminate ...'
    crawler.join
    
    puts 'Bye!'
  end
end
