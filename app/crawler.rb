class Crawler    
  require 'net/http'
  require './app/dal/queries'
  require './app/html_processor'
  
  THROTTLE_STOP = 7     # 7am
  THROTTLE_START = 19   # 7pm
  THROTTLED_DELAY = 10  # 10s break between requests
  UNTHROTTLED_DELAY = 1 # 1s break between requests
  
  def run(server)
    error = false
    Logger.info('[Crawler] Crawler started')
    while (!server.terminated) do
      begin
        url = pick_page_to_crawl
        Logger.info("[Crawler] Crawling #{url}")
        puts "#{Time.new} | Crawling #{url}"
        crawl_and_update_index(url)
        wait
      rescue => e
        Logger.info("Crawler Exception: #{e}")
        raise e # debug only        
      end
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
    puts "Got links: #{links}"
    sites = Queries.get_sites
    links.each do |l|
      # Only include links to stuff that's already an indexed site
      sites.each do |s|
        raise "SITE IS #{s}"
        if l.include?("://#{s}") || l.include?("://www.#{s}")
          Queries.add_to_queue(l)
          break
        end
      end
    end
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
    # page-requisites and convert-links downloads css, images, etc.
    # some sites return a 403 if you do this without a user agent; specify one with --user-agent
    # --reject-regex '(.*)\?(.*)' rejects URLs with query parameters, but only works in 1.14+
    `wget --page-requisites --html-extension --no-parent --convert-links --wait=1 --user-agent='Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.6) Gecko/20070802 SeaMonkey/1.1.4' --quiet=on -P data/sites #{url}`
  end
end
