class Server

  PORT = 9292
  include Rack
  
  attr_reader :terminated
  
  def run
    @terminated = false
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
    
    Database.create_if_missing()
    puts "Serving static content from #{Dir.pwd}"

    Handler::Thin.run app, :Port => PORT
        
    @terminated = true
  end
end
