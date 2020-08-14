require 'nokogiri'
require 'open-uri'
require 'watir'

class Scraper < ApplicationRecord
  def self.scrape_collector_square_price_data
    Handbag.with_reference_no.each do |handbag|
      new_price = self.scrape_from_collector_square(handbag.reference_no)
      next if handbag.prices.latest.price.to_f == new_price
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
          next if persisted_handbag.prices.latest.price.to_f == price[1..-1].to_f
          persisted_handbag.prices.create(price: price[1..-1].to_f, currency: price[0])
        else
          handbag = Handbag.create(name: name, website: website, condition: condition, product_id: product_id, brand: brand)
          if bag_div.css('.bc-sf-filter-product-item-original-price').present?
            previous_price = bag_div.css('.bc-sf-filter-product-item-original-price').text.gsub(',', '').gsub(/\s+/, "")
            handbag.prices.create(price: previous_price[1..-1].to_f, currency: previous_price[0])
          end
          handbag.prices.create(price: price[1..-1].to_f, currency: price[0])
        end
      end
      page_num += 1
      doc  = Nokogiri::HTML(open("#{uri}?page=#{page_num}"))
      all_handbags = doc.css('#bc-sf-filter-products').css('li')
    end
  end

  def self.scrape_from_fashion_phile
    uri = 'https://www.fashionphile.com/shop/categories/handbag-styles/'

    browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222]
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
        if persisted_handbag.present?
          next if persisted_handbag.prices.latest.price.to_f == price[1..-1].to_f
          persisted_handbag.prices.create(price: price[1..-1].to_f, currency: price[0])
        else
          handbag = Handbag.create(name: name, website: website, product_id: product_id, brand: brand, image: image)
          handbag.prices.create(price: price[1..-1].to_f, currency: price[0])
        end
      end
      browser.close

      browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222]
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
        product_id = bag_div.css('.item-main-info').css('.fav-outer-container').css('.favorites-toggle').attribute('data-wishlist-product-id')&.value

        price = bag_div.css('.price-box').css('.special-price').css('.price')
        if price.length > 1
          new_price = price[0].text.gsub(',', '').gsub(/\s+/, "")
          previous_price = price[1].text.gsub(',', '').gsub(/\s+/, "")
        else
          new_price = price.text.gsub(',', '').gsub(/\s+/, "")
        end

        persisted_handbag = Handbag.find_by(product_id: product_id)

        if persisted_handbag.present?
          next if persisted_handbag.prices.latest.price.to_f == new_price[1..-1].to_f
          persisted_handbag.prices.create(price: new_price[1..-1], currency: new_price[0])
        else
          handbag = Handbag.create(name: name, website: website, condition: condition, product_id: product_id, brand: brand)
          if previous_price.present?
            handbag.prices.create(price: previous_price[1..-1].to_f, currency: previous_price[0])
          end
          handbag.prices.create(price: new_price[1..-1].to_f, currency: new_price[0])
        end
      end
      page_num += 1
      doc  = Nokogiri::HTML(open("#{uri}?p=#{page_num}"))
      all_handbags = doc.css('.products-grid').css('.item')
    end
  end

  def self.scrape_from_whatgoesaroundnyc
    uri = 'https://www.whatgoesaroundnyc.com/bags.html'
    html = open(uri)
    doc  = Nokogiri::HTML(html)
    all_handbags = doc.css('.products').css('.item')
    page_num = 1

    while all_handbags.present?
      all_handbags.each do |bag_div|
        website = bag_div.css('.product-item-details').css('.product-item-link').attribute('href').value
        name  = bag_div.css('.product-item-details').css('.product-item-link').text.strip
        image = bag_div.css('.images-container').css('.product-image-wrapper').css('picture')[0].css('source').attribute('data-srcset').value
        brand = bag_div.css('.product-item-details').css('.brand').text.strip
        product_id = bag_div.css('.product-item-details').css('.price-final_price').attribute('data-product-id')&.value
        price = bag_div.css('.product-item-details').css('.price-final_price').css('.price-wrapper').attribute('data-price-amount')&.value
        next unless price.present?

        price = price.gsub(',', '').gsub(/\s+/, "")
        persisted_handbag = Handbag.find_by(product_id: product_id)
        if persisted_handbag.present?
          next if persisted_handbag.prices.latest.price.to_f == price.to_f
          persisted_handbag.prices.create(price: price.to_f, currency: '$')
        else
          handbag = Handbag.create(name: name, website: website, image: image, product_id: product_id, brand: brand)
          handbag.prices.create(price: price.to_f, currency: '$')
        end
      end
      break if doc.css('.toolbar-products').css('.pages-items').css('.pages-item-next').blank?

      page_num += 1
      doc  = Nokogiri::HTML(open("#{uri}?p=#{page_num}"))
      all_handbags = doc.css('.products-grid').css('.item')
    end
  end

  def self.scrape_from_vestiairecollective
    uri = 'https://www.vestiairecollective.com/women-bags/'
    basic_fitler = '#category=Bags#5 > Handbags#59'
    browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222]
    browser.goto "#{uri}#{basic_fitler}"
    sleep 10

    filter_doc  = Nokogiri::HTML(browser.html)
    filters = filter_doc.css('.catalog__filters').css('.filters__checkboxList__scroll').first.css('li')
    browser.close
    filters.each do |filter|
      current_filter = filter.css('label').text.split('(').first.strip
      filter_id = filter.css('input').attribute('id').value.split('_').last
      current_uri = "#{uri}#{basic_fitler}_brand=#{current_filter}##{filter_id}"

      browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222]
      browser.goto current_uri
      sleep 10
      doc  = Nokogiri::HTML(browser.html)
      all_handbags = doc.css('.row--gutter10').css('li')
      page_num = 1
      browser.close

      while all_handbags.present?
        all_handbags.each do |bag_div|
          website = bag_div.css('.productSnippet__price').css('meta').attribute('content').value
          name  = bag_div.css('.productSnippet__infos').css('.productSnippet__text--name').text.strip
          image = bag_div.css('.productSnippet__imageWrapper__image').css('.image').attribute('src').value
          brand = bag_div.css('.productSnippet__infos').css('.productSnippet__text--brand').text.strip
          product_id = bag_div.css('.productSnippet').css('vc-ref').children.css('meta').first.attribute('content').value
          sold = bag_div.css('.productSnippet').attribute('class').value.include? 'sold'
          price = bag_div.css('.productSnippet__infos').css('.productSnippet__price').css('span').last.text
          previous_price = bag_div.css('.productSnippet__price').css('.productSnippet__regularPrice').text
          next unless price.present?

          price = price.gsub(',', '').gsub(/\s+/, "")
          persisted_handbag = Handbag.find_by(product_id: product_id)
          if persisted_handbag.present?
            latest_price = persisted_handbag.prices.latest
            next if latest_price.present? && latest_price.price.to_f == price.to_f
            persisted_handbag.prices.create(price: price, currency: '£')
          else
            handbag = Handbag.create(name: name, website: website, image: image, product_id: product_id, brand: brand, sold: sold)
            if previous_price.present?
              previous_price = previous_price.gsub(',', '').gsub(/\s+/, "")[1..-1]
              handbag.prices.create(price: previous_price.to_f, currency: '£')
            end
            handbag.prices.create(price: price.to_f, currency: '£')

            bag_browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222]
            bag_browser.goto website
            sleep 10
            data  = Nokogiri::HTML(bag_browser.html)
            handbag_data = data.css('.descriptionList').css('.descriptionList__block__list').css('li')
            handbag_data.each do |bag_data|
              attribute = bag_data.text.split(':').first.downcase
              value     = bag_data.text.split(':').last.strip
              bag_text = bag_data.text.downcase
              if attribute.eql?('online since') || attribute.eql?('colour') || attribute.eql?('condition') || attribute.eql?('material') || attribute.eql?('model') || attribute.eql?('width') || attribute.eql?('height') || attribute.eql?('depth')
                attribute.gsub!('depth', 'length') if attribute.eql?('depth')
                attribute.gsub!('colour', 'color') if attribute.eql?('colour')
                handbag.update_attribute("#{attribute.strip.gsub(' ', '_')}", value)
              end
            end
            bag_browser.close
          end
        end
        browser.close
        break if doc.css('.catalogPagination__pageLink').last.attribute('class').value.include? 'catalogPagination__pageLink--active'

        page_num += 1
        browser = Watir::Browser.new :chrome, args: %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222]
        browser.goto "#{uri}p-#{page_num}/#{basic_fitler}_brand=#{current_filter}##{filter_id}"
        sleep 10
        doc  = Nokogiri::HTML(browser.html)
        all_handbags = doc.css('.row--gutter10').css('li')
      end
    end
  end

  def self.scrape_prices_data
    scrape_collector_square_price_data
    scrape_from_shop_rebag
    scrape_from_fashion_phile
    scrape_from_yoogiscloset
    scrape_from_whatgoesaroundnyc
  end

  private

  def self.scrape_from_collector_square(reference_no)
    collector_square_uri = 'https://www.collectorsquare.com/recherche?search%5Bkeywords%5D='
    html = open(collector_square_uri + reference_no.to_s)
    doc  = Nokogiri::HTML(html)

    doc.css('.price-cs').css('span').children.attribute("content")&.value.to_f
  end
end
