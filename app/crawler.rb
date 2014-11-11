class Crawler  
  require './app/dal/database'
  
  THROTTLE_STOP = 7     # 7am
  THROTTLE_START = 19   # 7pm
  THROTTLED_DELAY = 10  # 10s break between requests
  UNTHROTTLED_DELAY = 1 # 1s break between requests
  
  def run(server)
    while (!server.exit) do
      # Pick randomly or by date, or both
      # Wait, page queue bro?
      # Crawl
      # Update index
      
      wait
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
end
