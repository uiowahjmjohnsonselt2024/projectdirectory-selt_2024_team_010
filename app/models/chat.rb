# frozen_string_literal: true

class Chat < ActiveRecord::Base
  belongs_to :game
  validates :time_sent, presence: true
end
