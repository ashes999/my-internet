class Crawler    
  require 'net/http'
  require './app/dal/queries'
  
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
    html = http_get(url)
    data = HtmlProcessor.new.process(url, html)
    Queries.index(data)
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
    return Net::HTTP.get(URI.parse(url))
  end
  
  def store_as_file(data)
    filename = data[:filename] # includes path, eg. stackoverflow.com/...
    content = data[:raw_html]
    File.write("data/sites/#{filename}"content)
  end
end
