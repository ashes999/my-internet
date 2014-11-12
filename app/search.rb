class Search
  require 'cgi'
  require './app/dal/queries'
  
  SNIPPET_LENGTH = 200 # characters

  # TODO: separate content from presentation?
  def handle_search(env)
    query_string = env['QUERY_STRING']
    query = query_string[query_string.index('q=') + 2, query_string.length]
    query = CGI::unescape(query)
    
    results = Queries.search_for(query)
    # common header. TODO: DRY it.
    html = '<html><body>'
    html += '<form action="search" method="GET"><input id="q" name="q" /></form>'
    
    if results.length == 0
      html += '<p>No results found</p>'
    else
      results.each do |row|
        html += to_html(row, query)
      end
    end
    
    html += '</body></html>' # common footer. TODO: DRY it.
    
    return html
  end
  
  def to_html(row, query)
    # TODO: ERB/templatize.
    html = "<p><a href='/data/sites/#{row['original_url']}'>#{row['title']}</a><br />"
    html += "<span style='color: #080;'>#{row['original_url']}</span><br />"
    snippet = row['as_text']
    
    # Find the earliest start
    start = []
    query.split.each do |s|
      index = snippet.downcase.index(s.downcase)
      start.push(index) unless index.nil? || index < 0
    end
        
    snippet = snippet[start.min, SNIPPET_LENGTH]
    html += "#{snippet}</p>"
    return html
  end
end
