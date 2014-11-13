class Crawler    
  require './app/dal/queries'
  require './app/html_processor'
  
  THROTTLE_STOP = 7     # 7am
  THROTTLE_START = 19   # 7pm
  THROTTLED_DELAY = 10  # 10s break between requests
  UNTHROTTLED_DELAY = 1 # 1s break between requests  
  
  def initialize(sites_directory)
    @sites_directory = sites_directory
  end
  
  def run(server)
    Logger.info('[Crawler] Crawler started')
    while (!server.terminated) do
      begin
        url = pick_page_to_crawl
        Logger.info("[Crawler] Crawling #{url}")
        puts "#{Time.new} | Crawling #{url}"
        crawl(url)
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
  
  def wait
    hour = Time.new.hour
    if hour >= THROTTLE_STOP && hour <= THROTTLE_START
      delay = THROTTLED_DELAY
    else
      delay = UNTHROTTLED_DELAY
    end
    sleep(delay)
  end
  
  def crawl(url)
    # page-requisites and convert-links downloads css, images, etc.
    # some sites return a 403 if you do this without a user agent; specify one with --user-agent
    # --reject-regex '(.*)\?(.*)' rejects URLs with query parameters, but only works in 1.14+
    output = `wget --page-requisites --html-extension --no-parent --convert-links --wait=1 --user-agent='Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.6) Gecko/20070802 SeaMonkey/1.1.4' -P #{@sites_directory} #{url} 2>&1`
    filename = /Saving to: `([^`]+)`/.match(output)[1]
    filename = filename[0, filename.index("'")]
    Queries.link_file_to_url(filename, url)
  end
end
