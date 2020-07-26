class Handbag < ApplicationRecord
  has_one_attached :image
  has_many :prices

  BRAND = ["Alaïa", "Alexander McQueen", "Alexander Wang", "Balenciaga", "Berluti", "Bottega Veneta", "Bulgari", "Burberry", "Cartier", "Celine", "Chanel", "Chloé", "Christian Louboutin", "Dior", "Dolce & Gabbana", "Fauré Le Page", "Fendi", "Givenchy", "Goyard", "Gucci", "Hermès", "Jerome Dreyfuss", "John Galliano", "Lanvin", "Loewe", "Louis Vuitton", "Marc Jacobs", "Marni", "Miu Miu", "Moreau", "Mulberry", "Prada", "Ralph Lauren", "Renaud Pellegrino", "Rimowa", "Roger Vivier", "Saint Laurent", "Salvatore Ferragamo", "Stella McCartney", "Tod's", "Valentino Garavani", "Versace"]

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

  def self.filter_by(params)
    handbags = []
    handbags = self.where('name LIKE ?', "%#{params["brand"]}%") if params["brand"].present?
    handbags = handbags.any? ? handbags.where(model: params["model"]) : self.where(model: params["model"]) if params["model"].present?
    handbags = handbags.any? ? handbags.where(color: params["color"]) : self.where(color: params["color"]) if params["color"].present?
    handbags = handbags.any? ? handbags.where(color: params["length"]) : self.where(length: params["length"].to_i) if params["length"].present?
    handbags = handbags.any? ? handbags.where(color: params["height"]) : self.where(height: params["height"].to_i) if params["height"].present?
    handbags = handbags.any? ? handbags.where(color: params["width"]) : self.where(width: params["width"].to_i) if params["width"].present?
    handbags
  end
end
