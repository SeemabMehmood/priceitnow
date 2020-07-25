class Handbag < ApplicationRecord
  has_one_attached :image
  has_many :prices
end
