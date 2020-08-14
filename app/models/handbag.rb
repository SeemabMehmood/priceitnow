class Handbag < ApplicationRecord
  has_many :prices, dependent: :destroy

  BRAND = ["Alaïa", "Alexander McQueen", "Alexander Wang", "Balenciaga", "Berluti", "Bottega Veneta", "Bulgari", "Burberry", "Cartier", "Celine", "Chanel", "Chloé", "Christian Louboutin", "Dior", "Dolce & Gabbana", "Fauré Le Page", "Fendi", "Givenchy", "Goyard", "Gucci", "Hermès", "Jerome Dreyfuss", "John Galliano", "Lanvin", "Loewe", "Louis Vuitton", "Marc Jacobs", "Marni", "Miu Miu", "Moreau", "Mulberry", "Prada", "Ralph Lauren", "Renaud Pellegrino", "Rimowa", "Roger Vivier", "Saint Laurent", "Salvatore Ferragamo", "Stella McCartney", "Tod's", "Valentino Garavani", "Versace"]

  scope :with_reference_no, -> { where.not(reference_no: nil) }

  def self.models
    pluck(:model).reject(&:blank?).uniq.sort
  end

  def self.colors
    pluck(:color).reject(&:blank?).map{|k| k.include?(',') ? k.split(',').map(&:split) : k }.flatten.uniq.sort
  end

  def self.lengths
    pluck(:length).reject(&:blank?).uniq.sort.delete_if { |n| n==0 }
  end

  def self.widths
    pluck(:width).reject(&:blank?).uniq.sort.delete_if { |n| n==0 }
  end

  def self.heights
    pluck(:height).reject(&:blank?).uniq.sort.delete_if { |n| n==0 }
  end

  def min_price
    prices.pluck(:price).map(&:to_f).min
  end

  def max_price
    prices.pluck(:price).map(&:to_f).max
  end

  def avg_price
    plucked_prices = self.prices.pluck(:price).map(&:to_f)
    plucked_prices.sum / plucked_prices.length
  end

  def self.max_price_handbag(handbags, max_price)
    handbags.includes(:prices).where(prices: { price: max_price }).last
  end

  def self.min_price_handbag(handbags)
    bags = handbags.includes(:prices)
    bags.where(prices: { price: bags.map(&:min_price).min }).last
  end

  def self.avg_price_handbag(handbags, avg_price, max_price)
    bags = handbags.includes(:prices)
    bags.where('prices.price < ? AND prices.price > ?', max_price, avg_price).references(:prices).last
  end

  def self.filter_by(params)
    handbags = []
    handbags = self.where('lower(name) LIKE ?', "%#{params["brand"].downcase}%").or(self.where('lower(brand) LIKE ?', params["brand"].downcase)).order(:created_at) if params["brand"].present?
    return [] if handbags.blank? && params["brand"].present?
    if params["model"].present?
      if handbags.any?
        handbags = handbags.where(model: params["model"])
        return [] if handbags.blank?
      else
       handbags = self.where(model: params["model"])
      end
    end
    if params["color"].present?
      if handbags.any?
        handbags = handbags.where(color: params["color"])
        return [] if handbags.blank?
      else
       handbags = self.where(color: params["color"])
      end
    end
    if params["length"].present?
      if handbags.any?
        handbags = handbags.where(length: params["length"])
        return [] if handbags.blank?
      else
        handbags = self.where(length: params["length"].to_i)
      end
    end
    if params["height"].present?
      if handbags.any?
        handbags = handbags.where(height: params["height"])
        return [] if handbags.blank?
      else
        handbags = self.where(height: params["height"].to_i)
      end
    end
    if params["width"].present?
      if handbags.any?
        handbags = handbags.where(width: params["width"])
      else
       handbags = self.where(width: params["width"].to_i)
      end
    end
    handbags.any? ? handbags.includes(:prices) : []
  end
end
