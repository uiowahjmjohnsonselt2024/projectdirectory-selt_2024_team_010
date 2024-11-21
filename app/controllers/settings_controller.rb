class SettingsController < ApplicationController
  before_action :require_login
  def index
    @current_user = current_user
  end
end