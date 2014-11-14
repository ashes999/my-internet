class HtmlProcessor
  require 'rubygems'
  require 'nokogiri'
  require 'cgi'
  
  def process(url, html)
    to_return = { :original_url => normalize_url(url), :raw_html => html }
    to_return[:title] = content_between_tags(html, 'title') || '(Untitled Page)'
    to_return[:as_text] = as_text(html)
    filename = Queries.filename_for_url(url)
    to_return[:filename] = filename
    to_return[:domain] = filename[0, filename.index('/')]
    to_return[:last_indexed_on] = Time.new
    return to_return
  end
  
  def get_links(domain, html)
    return Nokogiri::HTML(html).css("a").map do |link|
      if (href = link.attr("href")) && href.match(/^https?:/)
        href
      end
    end.compact    
  end

  private
  
  def normalize_url(url)
    # strip out the protocol, and www.
    to_return = url.sub('/www.', '/').sub('http://', '')
    # strip out the query string
    to_return = to_return[0, to_return.index('?')] if to_return.include?('?')
    # strip out the trailing slash
    to_return = to_return[0, to_return.length - 1] if to_return[-1] = '/'
    return to_return
  end
  
  def content_between_tags(html, tag)
    return html.scan(/<#{tag}>([^<>]*)<\/#{tag}>/im).flatten.first
  end
  
  def as_text(html)
    return Nokogiri::HTML(html).text
  end
end
