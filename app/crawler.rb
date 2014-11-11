class Crawler    
  require 'net/http'
  require './app/dal/queries'
  require './app/html_processor'
  
  THROTTLE_STOP = 7     # 7am
  THROTTLE_START = 19   # 7pm
  THROTTLED_DELAY = 10  # 10s break between requests
  UNTHROTTLED_DELAY = 1 # 1s break between requests
  
  def run(server)
    while (!server.terminated) do
      url = pick_page_to_crawl
      crawl_and_update_index(url)
      wait
    end
  end
  
  private
  
  def pick_page_to_crawl
    # We need to balance re-indexing existing pages and crawling new pages
    # To keep things simple, pick a randomized mix of both.
    new_pages = Queries.get_unindexed_pages
    existing_pages = Queries.get_indexed_pages
    pool = (new_pages + existing_pages).shuffle
    return pool.first
  end
  
  def crawl_and_update_index(url)
    processor = HtmlProcessor.new
    
    html = http_get(url)
    data = processor.process(url, html)
    Queries.index(data)
    
    links = processor.get_links(data[:domain], html)
    sites = Queries.get_sites
    links.each do |l|
      # Only include links to stuff that's already an indexed site
      sites.each do |s|
        if l.include?(s)
          Queries.add_to_queue(l)
          break
        end
      end
    end
    store_as_file(data)
  end
  
  def wait
    hour = Time.new.hour
    if hour >= THROTTLE_STOP && hour <= THROTTLE_START
      delay = THROTTLED_DELAY
    else
      delay = UNTHROTTLED_DELAY
    end
    sleep(delay)
  end
  
  def http_get(url)
    return Net::HTTP.get(URI.parse("http://#{url}"))
  end
  
  def store_as_file(data)
    filename = data[:filename] # includes path, eg. stackoverflow.com/...
    content = data[:raw_html]
    path = filename[0, filename.rindex('/')]
    FileUtils.mkdir_p("data/sites/#{path}")
    File.write("data/sites/#{filename}", content)
  end
end
