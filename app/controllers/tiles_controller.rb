# frozen_string_literal: true
require 'openai'
require 'dotenv'
require 'openAIService'
require 'base64'
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

  def get_image
    x = params[:x]
    y = params[:y]
    tile = @current_game.tiles.find_by(x_position: x, y_position: y)
    if tile
      # If tile has no generated content, generate it
      if tile.picture.present?
        # serve the cached generated content. https://stackoverflow.com/a/29614032
        render text: Base64.decode64(tile.picture), content_type: 'image/png'
      else
        # generate it in the background and render a "loading" image
        unless tile.picture_generating?
          GenerateTileImageJob.perform_later(tile.id)
          tile.picture_generating = true
        end
        render file: Rails.root.join('public', 'loading.png').read
      end
    else
      render json: { error: 'Tile not found' }, status: 404
    end
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
      # If tile has no generated content, generate it
      if isGenerated(tile)
        ai_generated_content = generate_tile_text(tile)
        tile.update!(
          scene_description: ai_generated_content[:scene_description],
          treasure_description: ai_generated_content[:treasure_description],
          monster_description: ai_generated_content[:monster_description]
        )
      end

      render json: {
        x: tile.x_position,
        y: tile.y_position,
        biome: tile.biome,
        scene_description: tile.scene_description,
        treasure_description: tile.treasure_description,
        monster_description: tile.monster_description
      }
    else
      render json: { error: 'Tile not found' }, status: 404
    end
  end

  def generate_tile_text(tile)

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
      scene_description: parsed_response.dig(:landscape, :description) || "Default scene description",
      treasure_description: parsed_response.dig(:loot, :name) || "Default treasure description",
      monster_description: parsed_response.dig(:monster, :description) || "Default monster description"
    }
  end

  def generate_tile_image(tile)
    generator = @generator

    # scene prompt is passed in here and some sugar is added before properly requesting the image.
    image_prompt = <<~PROMPT
      You are to generate a scene for a fantasy MMORPG game. A game developer has described the scene as follows:
      #{tile.scene_description}
    PROMPT
    # in the future: we could pass in an adjacent tile to give it a scene of reference so images could be kinda "contiguous".
    # but thats for another time.

    generator.generate_image(image_prompt)

    # generate the pic.
    generate_image(generator, parsed_response.dig(:landscape, :description))
  end

  def loot_tile
    x = params[:x].to_i
    y = params[:y].to_i

    tile = Tile.find_by(x_position: x, y_position: y)
    if tile && tile.treasure_description.present?
      puts "Treasure taken"
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

  # small macro to test if ai content exists and is generated
  def isGenerated(tile)
    tile.picture.blank? && tile.scene_description.blank? && tile.treasure_description.blank? && tile.monster_description.blank?
  end

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
