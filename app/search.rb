class Search
  require 'cgi'
  require './app/dal/database'

  def handle_search(env)
    query_string = env['QUERY_STRING']
    query = query_string[query_string.index('q=') + 2, query_string.length]
    query = CGI::unescape(query)
    
    results = Database.search_for(query)
    # include common header
    # include search form. it's hard-coded.
    html = '<html><body>'
    html += '<form action="search" method="GET"><input id="q" name="q" /></form>'
    html += '<p>No results found</p>' if results.length == 0
    html += '</body></html>'
    
    return html
  end
end
