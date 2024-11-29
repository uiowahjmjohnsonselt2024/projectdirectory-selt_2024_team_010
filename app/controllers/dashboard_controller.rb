class DashboardController < ApplicationController
  before_action :require_login, :get_current_game
  def index
  end
end