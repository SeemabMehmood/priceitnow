require 'nokogiri'
require 'open-uri'

class Scraper < ApplicationRecord
  def self.scrape_collector_square_price_data
    Handbag.with_reference_no.each do |handbag|
      new_price = self.scrape_from_collector_square(handbag.reference_no)
      next if handbag.prices.latest.price == new_price
      handbag.prices.create(price: new_price)
      puts "New price found for handbag #{handbag.reference_no}"
    end
  end

  def self.scrape_from_shop_rebag
    uri = 'https://shop.rebag.com/collections/all-bags'
    html = open(uri)
    doc  = Nokogiri::HTML(html)
    all_handbags = doc.css('#bc-sf-filter-products').css('li')
    page_num = 1
    while all_handbags.present?
      all_handbags.each do |bag_div|
        website = 'https://shop.rebag.com' + bag_div.css('.product-caption').css('.product-vendor').attribute('href')
        name = bag_div.css('.product-caption').css('.product-title').text.strip
        brand = bag_div.css('.product-caption').css('.product-vendor').text
        condition = bag_div.css('.product-caption').css('.product-condition').text
        product_id = bag_div.css('.favorite-container').attribute('data-product-id').value

        price = bag_div.css('.product-price').text.gsub(',', '').gsub(/\s+/, "")
        persisted_handbag = Handbag.find_by(product_id: product_id)

        if persisted_handbag.present?
          next if persisted_handbag.prices.latest.price == price[1..-1]
          persisted_handbag.prices.create(price: price[1..-1], currency: price[0])
        else
          handbag = Handbag.create(name: name, website: website, condition: condition, product_id: product_id, brand: brand)
          if bag_div.css('.bc-sf-filter-product-item-original-price').present?
            previous_price = bag_div.css('.bc-sf-filter-product-item-original-price').text.gsub(',', '').gsub(/\s+/, "")
            handbag.prices.create(price: previous_price[1..-1], currency: previous_price[0])
          end
          handbag.prices.create(price: price[1..-1], currency: price[0])
        end
      end
      page_num += 1
      doc  = Nokogiri::HTML(open("#{uri}?page=#{page_num}"))
      all_handbags = doc.css('#bc-sf-filter-products').css('li')
    end
  end

  def self.scrape_prices_data
    scrape_collector_square_price_data
    scrape_from_shop_rebag
  end

  private

  def self.scrape_from_collector_square(reference_no)
    collector_square_uri = 'https://www.collectorsquare.com/recherche?search%5Bkeywords%5D='
    html = open(collector_square_uri + reference_no.to_s)
    doc  = Nokogiri::HTML(html)

    doc.css('.price-cs').css('span').children.attribute("content")&.value
  end
end
