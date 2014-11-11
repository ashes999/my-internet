# Business-level functions to execute on the database.
# Like an ORM, or Java's repository pattern, or ActiveRecord
class Queries
  require './app/dal/database'
  
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
    
    return Database.query(sql)
  end
  
  def self.get_unindexed_pages
    sql = 'SELECT url FROM pageQueue'
    return Database.query(sql)
  end
  
  def self.get_indexed_pages
    sql = 'SELECT original_url FROM pages'
    return Database.query(sql)
  end
  
  def self.index(data)
    # TODO. Include page_id and site_id as appropriate.
    # TODO: remove from unindexed pages queue.
  end
  
  private
  
  def initialize
    raise 'Can\'t initialize static classes'
  end
end
