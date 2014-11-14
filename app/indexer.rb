class Indexer
  
  require './app/server'
  require './app/html_processor'
  require './app/utils/logger'
  
  def initialize(sites_directory)
    @sites_directory = sites_directory
  end
  
  def run(server)
    processor = HtmlProcessor.new
    Logger.info('[Indexer] Indexer started')
    while !server.terminated do
      files = Dir.glob('data/sites/**/*.html')
      Logger.info("[Indexer] #{files.length} files to index")
      files.each do |f|
        html = File.read(f)
        url = Queries.url_for_file(f)
        if !url.nil?
          data = processor.process(url, html)
          Queries.index(data)
          
          links = processor.get_links(data[:domain], html)
          sites = Queries.get_sites
          links.each do |l|
            # Only include links to stuff that's already an indexed site
            sites.each do |s|
              if l.include?("://#{s}") || l.include?("://www.#{s}")
                Queries.add_to_queue(l)
                break
              end
            end
          end
          Logger.info("Indexed #{f}")
        else
          Logger.info("ERROR: URL not found for #{f}")
        end
      end
      sleep(5) # Shouldn't be necessary since crawling is constant, but beats a busy  loop.
    end
  end
end
