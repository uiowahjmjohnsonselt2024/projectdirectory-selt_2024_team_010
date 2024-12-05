# frozen_string_literal: true
require 'openai'
require 'dotenv'
require 'openAIService'
Dotenv.load



class TilesController < ApplicationController
  before_action :require_login, :get_current_game, :initialize_generator
  BIOMES = [:white, :green, :yellow, :gray, :blue]
  def create
    x = params[:x]
    y = params[:y]
    # This is just a check to prevent overwriting a tile using CREATE. UPDATE should be used if that is needed.
    unless @current_game&.tiles&.where("x_position = ? AND y_position = ?",x,y) then return end
    # Replace biome selector with something fancier if we have the time.
    @current_game.tiles.create!(x_position: x, y_position: y, biome: BIOMES.sample)
  end

  def get_tile
    x = params[:x].to_i
    y = params[:y].to_i

    tile = Tile.find_by(x_position: x, y_position: y)
    if tile
      # Check if all fields are blank
      if tile.picture.blank? && tile.scene_description.blank? && tile.treasure_description.blank? && tile.monster_description.blank?
        # Generate AI content
        ai_generated_content = generate_tile_content(tile)

        # Update the tile with the generated content
        tile.update!(
          picture: ai_generated_content[:picture],
          scene_description: ai_generated_content[:scene_description],
          treasure_description: ai_generated_content[:treasure_description],
          monster_description: ai_generated_content[:monster_description]
        )
      end

      render json: {
        x: tile.x_position,
        y: tile.y_position,
        biome: tile.biome,
        picture: tile.picture,
        scene_description: tile.scene_description,
        treasure_description: tile.treasure_description,
        monster_description: tile.monster_description
      }
    else
      render json: { error: 'Tile not found' }, status: 404
    end
  end


  def generate_tile_content(tile)
    generator = @generator

    # Prepare prompts for the AI
    system_prompt = <<~PROMPT
    You are a creative generator for a video game project. I will give you
    specifications on what to generate (a text description of a monster, a treasure, or
    the landscape), and you will return your responses in JSON format as seen below. If my
    instructions have no mention of either monster, landscape, or loot, then do not return
    anything for those sections. Only return the specified information.
    {
      "monster": {
        "description": "[Monster description placeholder]",
        "level": 0
      },
      "landscape": {
        "description": "[Landscape description placeholder]"
      },
      "loot": {
        "name": "[Loot name placeholder]",
        "rarity": "[Loot rarity placeholder]",
        "level": 0
      }
    }
  PROMPT

    instruction_prompt = <<~INSTRUCTION
    Generate content for a tile in the #{tile.biome} biome.
    Include:
    - A landscape description
    - A treasure description
    - A monster description
  INSTRUCTION

    # Call the GameContentGenerator service
    response = generator.generate_content("gpt-4o-mini", system_prompt, instruction_prompt)

    parsed_response = JSON.parse(response, symbolize_names: true)
    {
      picture: parsed_response.dig(:landscape, :description) || "Default picture",
      scene_description: parsed_response.dig(:landscape, :description) || "Default scene description",
      treasure_description: parsed_response.dig(:loot, :name) || "Default treasure description",
      monster_description: parsed_response.dig(:monster, :description) || "Default monster description"
    }
  end

  private

  def initialize_generator
    api_key = ENV['OPENAI_API_KEY']
    @generator = GameContentGenerator.new(api_key)
  end

end
