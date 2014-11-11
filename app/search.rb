class Search
  require 'cgi'
  require './app/dal/database'

  def handle_search(env)
    query_string = env['QUERY_STRING']
    query = query_string[query_string.index('q=') + 2, query_string.length]
    query = CGI::unescape(query)
    
    results = Database.search_for(query)
    # common header. TODO: DRY it.
    html = '<html><body>'
    html += '<form action="search" method="GET"><input id="q" name="q" /></form>'
    
    if results.length == 0
      html += '<p>No results found</p>'
    else
      results.each do |r|
        html += to_html(r)
      end
    end
    
    html += '</body></html>' # common footer. TODO: DRY it.
    
    return html
  end
  
  def to_html(row)
    # TODO: ERB/templatize.
    return "<p><a href='#{row['original_url']}'>#{row['title']}</a><br />#{row['as_text']}</p>"
  end
end
