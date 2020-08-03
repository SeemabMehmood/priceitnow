class HandbagsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def dashboard
  end

  def filter_results
    @handbags = Handbag.filter_by(params)
    @max_price = @handbags.map { |h| h.max_price }.max
    @min_price = @handbags.map { |h| h.min_price }.min
    avg_prices = @handbags.map { |h| h.avg_price }
    @avg_price = avg_prices.any? ? avg_prices.sum / avg_prices.length : 0
    @min_price = 0 if @min_price == @max_price
    @prices_data = @handbags.map { |h| h.prices.pluck(:price) }.flatten.uniq.map(&:to_i).sort
  end
end
