class Database # static class
  DB_FILE = 'data/production.sqlite3'
  
  require 'sqlite3'
  require './app/dal/migrations'

  def self.create_if_missing
    if !File.exist?(DB_FILE)
      Migrations.run_all
      puts 'Created new database'
    end
  end
  
  # TODO: handle upgrades (migrations?)

  def self.execute_scalar(query)
    begin        
      db = SQLite3::Database.new(DB_FILE)
      return db.get_first_value(query)
    ensure
      db.close if db
    end
  end
  
  def self.execute(query)
    begin        
      db = SQLite3::Database.new(DB_FILE)
      return db.execute(query)
    ensure
      db.close if db
    end
  end
  
  def self.search_for(query)
    words = query.split
    
    # Keep it in the same order
    sql = 'SELECT * FROM pages WHERE '
    for n in (0 ... words.length) do
      word = words[n]
      sql += "as_text LIKE '%#{word}%'"
      sql += ' OR ' if n < words.length - 1
    end    
    sql += ';'
    
    begin        
      db = SQLite3::Database.new(DB_FILE)
      db.results_as_hash = true
      return db.execute(sql)
    ensure
      db.close if db
    end
  end
  
  private
  
  # static class
  def initialize
    raise 'Can\'t instantiate a static calss.'
  end
  
end
