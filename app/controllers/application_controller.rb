class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def after_signin_path_for
    root_path
  end
end
