# frozen_string_literal: true
require 'openai'
require 'dotenv'
require 'game_content_generator'
Dotenv.load

class TilesController < ApplicationController
  @@generated_items = Set.new  # Use a class-level Set to store unique item names
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

    tile = @current_game.tiles.find_by(x_position: x, y_position: y)
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

    # No loot generation from AI. Only monster and landscape.
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

    # Custom loot logic
    roll = rand(100)
    treasure_description =
      if roll < 5
        # 5% item (call another GPT API to get a random artifact)
        generate_item(generator)
      elsif roll < 30
        # 25% none
        generate_item(generator)

      else
        # 70% shards
        #shards = rand(10..100)
        #"Shards:#{shards}"
        generate_item(generator)

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

    tile = @current_game.tiles.find_by(x_position: x, y_position: y)
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

    tile = @current_game.tiles.find_by(x_position: x, y_position: y)
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

  def generate_item(generator)
    # Here we craft a prompt to generate a single artifact description.
    # We'll include a list of previously generated names to prevent duplicates.

    used_names = @@generated_items.to_a
    name_list_str = used_names.empty? ? "[]" : used_names.map { |n| "\"#{n}\"" }.join(", ")

    item_system_prompt = <<~PROMPT
      You are a creative item generator for a fantasy game.
      You will return one item in JSON format with "name" and "description" keys only.
      Here is a list of previously generated item names: [#{name_list_str}]
      You must create a unique item name not present in the above list.
      Example:
      {
        "name": "Ancient Crystal Skull",
        "description": "A skull carved from crystal that emits a faint eerie glow."
      }
    PROMPT

    item_instruction_prompt = <<~INSTRUCTION
      Generate a single mysterious artifact item with a unique name and a short description.
      The name must not match any of the previously generated names given. It can be a
      weapon (sword, bow, staff, axe, hammer) or a shield (diamond, tower, round) or a 
      piece of armor (cloak, greaves, gauntlets, chestplate) or can just be a random artifact.
      Any of these can be made of many possible materials (wood, iron, steel, gold, jewels,
      shadows, sunlight, etc.) Get creative!
    INSTRUCTION

    # We'll allow a few retries just in case the model repeats a name.
    3.times do
      item_response = generator.generate_content("gpt-4o-mini", item_system_prompt, item_instruction_prompt)

      # Remove Markdown code fences if they exist
      clean_response = item_response.gsub(/^```json\s*/, '').gsub(/```$/, '')

      begin
        item_data = JSON.parse(clean_response, symbolize_names: true)
        item_name = item_data[:name].strip

        # Check if it's already used
        unless @@generated_items.include?(item_name)
          # It's unique, store it and return
          @@generated_items.add(item_name)
          return "#{item_name}: #{item_data[:description]}"
        end
      rescue JSON::ParserError => e
        puts "Error parsing JSON: #{e.message}"
      end
    end

    # If we reach here, we failed to get a unique name after several attempts
    # Fall back to a generic item or raise an error
    "Unique Artifact of Mystery: A one-of-a-kind item you have never seen before."
  end

end
