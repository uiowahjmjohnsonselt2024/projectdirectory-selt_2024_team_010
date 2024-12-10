# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
require 'dotenv/load' if Rails.env.development? || Rails.env.test?
run Rails.application
