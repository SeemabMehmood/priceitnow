require 'nokogiri'
require 'open-uri'
require 'pry'

class Scraper < ApplicationRecord

  def self.scrape_from_collector_square(reference_no)
    collector_square_uri = 'https://www.collectorsquare.com/recherche?search%5Bkeywords%5D='
    html = open(collector_square_uri + reference_no.to_s)
    doc  = Nokogiri::HTML(html)

    doc.css('.price-cs').css('span').children.attribute("content").value
  end
end
