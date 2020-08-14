every 1.day, at: '12:00 AM' do
  runner 'Scraper.scrape_prices_data'
end

every 1.day, at: '03:00 AM' do
  runner 'Scraper.scrape_from_vestiairecollective'
end

set :output, "log/cron.log"