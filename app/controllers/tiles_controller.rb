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
    unless @current_game&.tiles&.where("x_position = ? AND y_position = ?", x, y)
      return
    end
    @current_game.tiles.create!(x_position: x, y_position: y, biome: BIOMES.sample)
  end

  def get_tile
    x = params[:x].to_i
    y = params[:y].to_i

    tile = Tile.find_by(x_position: x, y_position: y)
    if tile
      # If tile has no generated content, generate it
      if tile.picture.blank? && tile.scene_description.blank? && tile.treasure_description.blank? && tile.monster_description.blank?
        ai_generated_content = generate_tile_content(tile)
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

    # We will no longer ask the AI for loot. We'll only ask for monster and landscape.
    system_prompt = <<~PROMPT
      You are a creative generator for a video game project. I will give you
      specifications on what to generate (a text description of a monster and the landscape).
      Return your responses in JSON format with only "monster" and "landscape" keys.
      No loot generation is requested. Example JSON:
      {
        "monster": {
          "description": "[Monster description placeholder]",
          "level": 0
        },
        "landscape": {
          "description": "[Landscape description placeholder]"
        }
      }
    PROMPT

    instruction_prompt = <<~INSTRUCTION
      Generate content for a tile in the #{tile.biome} biome.
      Include:
      - A landscape description
      - A monster description
      Do not include any loot. Do not mention loot.
    INSTRUCTION

    response = generator.generate_content("gpt-4o-mini", system_prompt, instruction_prompt)
    parsed_response = JSON.parse(response, symbolize_names: true)

    # Now we handle loot ourselves:
    # 5%: an item (e.g. "A mysterious artifact")
    # 25%: no loot (nil)
    # 70%: shards (random between 10 and 100)
    roll = rand(100)
    treasure_description =
      if roll < 5
        # 5% item
        "A mysterious artifact"
      elsif roll < 30
        # 25% none
        nil
      else
        # 70% shards
        shards = rand(10..100)
        "Shards:#{shards}"
      end

    {
      picture: parsed_response.dig(:landscape, :description) || "Default picture",
      scene_description: parsed_response.dig(:landscape, :description) || "Default scene description",
      treasure_description: treasure_description,
      monster_description: parsed_response.dig(:monster, :description) || "Default monster description"
    }
  end

  def loot_tile
    x = params[:x].to_i
    y = params[:y].to_i

    tile = Tile.find_by(x_position: x, y_position: y)
    if tile && tile.treasure_description.present?
      treasure = tile.treasure_description
      if treasure.start_with?("Shards:")
        # Extract the amount of shards
        shard_amount = treasure.split(":")[1].to_i
        current_user.update!(shard_amount: current_user.shard_amount + shard_amount)
        puts "Shards collected: #{shard_amount}"
      else
        # It's an item
        puts "Treasure taken"
      end

      tile.update!(treasure_description: nil)
      render json: { success: true, tile: tile }
    else
      render json: { error: "No treasure to take." }, status: 404
    end
  end

  def fight_monster
    x = params[:x].to_i
    y = params[:y].to_i

    tile = Tile.find_by(x_position: x, y_position: y)
    if tile && tile.monster_description.present?
      puts "Monster slain"
      tile.update!(monster_description: nil)
      render json: { success: true, tile: tile }
    else
      render json: { error: "No monster to fight." }, status: 404
    end
  end

  private

  def initialize_generator
    api_key = ENV['OPENAI_API_KEY']
    @generator = GameContentGenerator.new(api_key)
  end

end
