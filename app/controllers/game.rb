# frozen_string_literal: true
class Game < ApplicationController
  before_action :require_login
  def index
  end
end