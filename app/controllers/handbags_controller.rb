class HandbagsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def dashboard
    @total_handbags = Handbag.count
    @updated_prices = Handbag.includes(:prices).select { |h| h.prices.length > 1 }.length
    @total_visitors = User.count
  end

  def index
    @handbags = Handbag.all.includes(:prices).order('created_at DESC')
  end

  def show
    @handbag = Handbag.find(params[:id])
    prices  = @handbag.prices.order('created_at ASC')
    @prices = prices.pluck(:price).map(&:to_i)
    @labels = prices.pluck(:created_at).map { |d| d.strftime('%d %B') }.uniq
  end

  def filter_results
    @handbags = Handbag.filter_by(params)
    @max_price = @handbags.map(&:max_price).max
    avg_prices = @handbags.map(&:avg_price)
    avg_price = avg_prices.any? ? avg_prices.sum / avg_prices.length : 0
    @max_price_handbag = Handbag.max_price_handbag(@handbags, @max_price)
    @avg_price_handbag = Handbag.avg_price_handbag(@handbags, avg_price, @max_price)
    @min_price_handbag = Handbag.min_price_handbag(@handbags)
    @range = (0..@max_price).step(@max_price/@handbags.count).to_a
    @prices_data = @handbags.map { |h| h.prices.pluck(:price) }.flatten.uniq.map(&:to_i).sort
  end
end
