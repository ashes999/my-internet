class Database
  DB_FILE = 'data/production.sqlite3'
  
  require 'sqlite3'

  def self.execute_scalar(query)
    begin        
        db = SQLite3::Database.new(DB_FILE)
        return db.get_first_value('SELECT SQLITE_VERSION()')
    rescue SQLite3::Exception => e         
        puts "Exception occurred: #{e}"
    ensure
        db.close if db
    end
  end
  
  private
  
  # Static class
  def initialize
  end
  
end
