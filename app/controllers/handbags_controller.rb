class HandbagsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def dashboard
  end

  def filter
    @handbags = Handbag.filter_by(params)
  end
end
