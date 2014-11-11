# Business-level functions to execute on the database.
# Like an ORM, or Java's repository pattern, or ActiveRecord
class Queries
  require './app/utils/logger'
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
  
  def self.add_to_queue(url)
    # Insert if it doesn't exist in the page queue, and if it's not indexed
    exists = Database.execute_scalar('SELECT 1 FROM pageQueue WHERE url = ?', url) || 0
    exists = Database.execute_scalar('SELECT 1 FROM pages where original_url = ?', url) || 0 unless exists == 1
    if exists.nil? || exists == 0
      Database.execute('INSERT INTO pageQueue (url) VALUES (?)', url) 
      Logger.info("Added #{url} to page queue")
    else
      Logger.info("#{url} skipped queue (already added)")
    end
  end
  
  def self.get_unindexed_pages
    sql = 'SELECT url FROM pageQueue'
    to_return = Database.execute(sql)
    Logger.info("Got #{to_return.count} un-indexed pages")
    return to_return.collect { |row| row['url'] }
  end
  
  def self.get_sites
    sql = 'SELECT domain FROM sites'
    to_return = Database.execute(sql)
    return to_return.collect { |row| row['domain'] }
  end
  
  def self.get_indexed_pages
    sql = 'SELECT original_url FROM pages'
    to_return = Database.execute(sql)
    Logger.info("Got #{to_return.count} indexed pages")
    return to_return.collect { |row| row['original_url'] }
  end
  
  def self.index(data)
    # URL is normalized, so site-finding is easy
    url = data[:original_url]
    if url.include?('/')
      domain = url[0, url.index('/')] # without the domain
    else
      domain = url
    end
    
    site_id = Database.execute_scalar('SELECT site_id FROM sites WHERE domain = ?', [domain])
    if site_id.nil? || site_id == 0 then
      Database.execute('INSERT INTO sites (domain) VALUES (?)', domain)
      site_id = Database.execute_scalar('SELECT site_id FROM sites WHERE domain = ?', [domain])
    end
    
    page_id = Database.execute_scalar('SELECT page_id FROM pages WHERE original_url = ?', [url])
    
    # TODO: probably a bad idea, but we have no references. Delete if existing (update = delete + re-insert)
    if page_id.nil? || page_id == 0 then
      Database.execute('DELETE FROM pages WHERE page_id = ?', [page_id])
    end
    
    Database.execute('INSERT INTO pages (original_url, title, filename, as_text, site_id, last_indexed_on) VALUES (?, ?, ?, ?, ?, ?)', [url, data[:title], data[:filename], data[:as_text], site_id, data[:last_indexed_on].to_s])    
  end
  
  private
  
  def initialize
    raise 'Can\'t initialize static classes'
  end
end
