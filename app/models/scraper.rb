require 'nokogiri'
require 'open-uri'
require 'watir'

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

  def self.scrape_from_fashion_phile
    uri = 'https://www.fashionphile.com/shop/categories/handbag-styles/'

    browser = Watir::Browser.new
    browser.goto uri
    sleep 10

    doc  = Nokogiri::HTML(browser.html)
    all_handbags = doc.css('.product_container')
    page_num = 1

    while all_handbags.present?
      all_handbags.each do |bag_div|
        website = bag_div.css('.thumbnail').css('a').attribute('href').value
        image = bag_div.css('.thumbnail').css('img').attribute('src').value
        name = bag_div.css('.caption').css('.product-title').attribute('content').value.strip
        brand = bag_div.css('.caption').css('.brand').text
        product_id = website.split('-').last
        price = bag_div.css('.caption').css('.sale-price').text.gsub(',', '').gsub(/\s+/, "")
        persisted_handbag = Handbag.find_by(product_id: product_id)
        puts product_id

        if persisted_handbag.present?
          next if persisted_handbag.prices.latest.price == price[1..-1]
          persisted_handbag.prices.create(price: price[1..-1], currency: price[0])
        else
          handbag = Handbag.create(name: name, website: website, product_id: product_id, brand: brand, image: image)
          handbag.prices.create(price: price[1..-1], currency: price[0])
        end
      end
      browser.close

      browser = Watir::Browser.new
      page_num += 1
      browser.goto "#{uri}?page=#{page_num}"
      sleep 10

      doc  = Nokogiri::HTML(browser.html)
      all_handbags = doc.css('.product_container')
    end
  end

  def self.scrape_from_yoogiscloset
    uri = 'https://www.yoogiscloset.com/handbags'
    html = open(uri)
    doc  = Nokogiri::HTML(html)
    all_handbags = doc.css('.products-grid').css('.item')
    page_num = 1

    while all_handbags.present?
      all_handbags.each do |bag_div|
        website = bag_div.css('.product-image-wrapper').css('a').attribute('href').value
        name = bag_div.css('.item-main-info').css('.product-name').css('a').attribute('title').value
        image = bag_div.css('.product-image-wrapper').css('.primary_image').attribute('src').value
        brand = bag_div.css('.item-main-info').css('.designer-name').text
        condition = bag_div.css('.product-list-attributes').css('.product-condition').children.children.text
        product_id = bag_div.css('.item-main-info').css('.fav-outer-container').css('.favorites-toggle').attribute('data-wishlist-product-id').value

        price = bag_div.css('.price-box').css('.special-price').css('.price')
        if price.length > 1
          new_price = price[0].text.gsub(',', '').gsub(/\s+/, "")
          previous_price = price[1].text.gsub(',', '').gsub(/\s+/, "")
        else
          new_price = price.text.gsub(',', '').gsub(/\s+/, "")
        end

        persisted_handbag = Handbag.find_by(product_id: product_id)

        if persisted_handbag.present?
          next if persisted_handbag.prices.latest.price == new_price[1..-1]
          persisted_handbag.prices.create(price: new_price[1..-1], currency: new_price[0])
        else
          handbag = Handbag.create(name: name, website: website, condition: condition, product_id: product_id, brand: brand)
          if previous_price.present?
            handbag.prices.create(price: previous_price[1..-1], currency: previous_price[0])
          end
          handbag.prices.create(price: new_price[1..-1], currency: new_price[0])
        end
      end
      page_num += 1
      doc  = Nokogiri::HTML(open("#{uri}?p=#{page_num}"))
      all_handbags = doc.css('.products-grid').css('.item')
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
