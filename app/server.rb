class Server

  PORT = 9292
  include Rack
  
  def run
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

    puts "Serving static content from #{Dir.pwd}"

    Handler::Thin.run app, :Port => PORT
  end
end
