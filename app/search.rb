class Search
  def handle_search(env)
    query_string = env['QUERY_STRING']
    query = query_string[query_string.index('q=') + 2, query_string.length]
    return "Hello, world! Here are the reuslts for #{query}"
  end
end
