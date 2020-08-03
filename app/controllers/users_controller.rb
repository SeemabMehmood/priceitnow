class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_logged_in?

  def index
    @users = User.all.order('created_at DESC')
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: 'User destroyed successfully!'
  end

  private
  def admin_logged_in?
    redirect_to root_path, error: 'You have no access to this page' unless current_user.admin?
  end
end
