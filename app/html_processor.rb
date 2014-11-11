class HtmlProcessor
  require 'rubygems'
  require 'nokogiri'
  require 'cgi'
  
  def process(url, html)
    to_return = { :original_url => url, :raw_html => html }
    to_return[:title] = p.content_between_tags(html, 'title') || '(Untitled Page)'
    to_return[:as_text] = p.as_text(html)
    to_return[:filename] = p.filename_for(url)
    to_return[:last_indexed_on] = Time.new
    return to_return
  end

  private
  
  def content_between_tags(html, tag)
    return html.scan(/<#{tag}>([^<>]*)<\/#{tag}>/im).flatten.first
  end
  
  def as_text(html)
    puts Nokogiri::HTML(html).text
  end
  
  def filename_for(url)
    normalized = url[url.index('://') + 3, url.length] if url.include?('://')
    domain = normalized[0, normalized.index('/')]
    filename = normalized[domain.length + 1, normalized.length]
    filename = CGI::unescape(filename)
    filename = filename.gsub(/[\+\-=_!@\#$%^&\*\(\) ,.\/\?\[\]\]]/, '-')
    filename = "#{domain}/#{filename}.html"
    return filename
  end

  private
  
  def initialize
    raise 'Can\'t initialize static classes'
  end
end
