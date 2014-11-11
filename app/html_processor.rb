class HtmlProcessor
  require 'rubygems'
  require 'nokogiri'
  require 'cgi'
  
  def process(url, html)
    to_return = { :original_url => normalize_url(url), :raw_html => html }
    to_return[:title] = content_between_tags(html, 'title') || '(Untitled Page)'
    to_return[:as_text] = as_text(html)
    filename = filename_for(url)
    to_return[:filename] = filename
    to_return[:domain] = filename[0, filename.index('/')] # normalized domain
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
    to_return = url.sub('/www.', '/').sub('http://', '')
    return to_return
  end
  
  def content_between_tags(html, tag)
    return html.scan(/<#{tag}>([^<>]*)<\/#{tag}>/im).flatten.first
  end
  
  def as_text(html)
    return Nokogiri::HTML(html).text
  end
  
  def filename_for(url)  
    normalized = url
    normalized = url[url.index('://') + 3, url.length] if url.include?('://')
    domain = normalized # Could be just "stackoverflow.com"
    domain = normalized[0, normalized.index('/')] if domain.include?('/')
    filename = normalized[domain.length + 1, normalized.length]
    if filename.nil?
      # eg. "stackoverflow.com"
      return "#{domain}/index.html"
    else
      filename = CGI::unescape(filename)
      filename = filename.gsub(/[\+\-=_!@\#$%^&\*\(\) ,.\/\?\[\]\]]/, '-')
      filename = "#{domain}/#{filename}.html"
      return filename
    end
  end
end
