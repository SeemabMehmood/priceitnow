require 'nokogiri'
require 'open-uri'

class Scraper < ApplicationRecord

  def self.scrape_data
    Handbag.with_reference_no.each do |handbag|
      new_price = self.scrape_from_collector_square(handbag.reference_no)
      next if handbag.prices.latest.price == new_price
      handbag.prices.create(price: new_price)
      puts "New price found for handbag #{handbag.reference_no}"
    end
  end

  private

  def self.scrape_from_collector_square(reference_no)
    collector_square_uri = 'https://www.collectorsquare.com/recherche?search%5Bkeywords%5D='
    html = open(collector_square_uri + reference_no.to_s)
    doc  = Nokogiri::HTML(html)

    doc.css('.price-cs').css('span').children.attribute("content")&.value
  end
end
