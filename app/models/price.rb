class Price < ApplicationRecord
  belongs_to :handbag

  scope :latest, -> { order('created_at DESC').first }
end
