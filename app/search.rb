class Search
  require './app/dal/database'
  
  def handle_search(env)
    query_string = env['QUERY_STRING']
    query = query_string[query_string.index('q=') + 2, query_string.length]
    return "The DB version is #{Database.execute_scalar('SELECT sqlite_version()')}"
  end
end
