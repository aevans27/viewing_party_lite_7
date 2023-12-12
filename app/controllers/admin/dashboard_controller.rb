class Admin::DashboardController < ApplicationController
  before_action :require_user

  def index

  end

  private
  def require_user
    # render :not_found
    redirect_to root_path unless current_user?
  end
end