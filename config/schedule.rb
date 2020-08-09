every 1.day, at: '12:00 AM' do
  runner 'Scraper.scrape_prices_data'
end

set :output, "log/cron.log"