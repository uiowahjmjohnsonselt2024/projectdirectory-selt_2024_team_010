# frozen_string_literal: true
require 'openai'
require 'openAIService'
require 'base64'

class TilesController < ApplicationController
  @@generated_items = Set.new  # Use a class-level Set to store unique item names
  before_action :require_login, :get_current_game
  BIOMES = {
    "white"  => "snow",
    "green"  => "plains",
    "yellow" => "desert",
    "gray"   => "mountains",
    "blue"   => "sea"
  }

  def get_image
    x = params[:x]
    y = params[:y]
    tile = @current_game.tiles.find_by(x_position: x, y_position: y)

    # first check if the tile exists.
    if tile
      # if it does, serve the cached generated content.
      if tile.picture.present? # https://stackoverflow.com/a/29614032
        render text: Base64.decode64(tile.picture), content_type: 'image/png'
      else
        # otherwise, generate it in the background and render a "loading" image
        send_file(Rails.root.join('public', 'loading.png'), type: "image/png", disposition: "inline")
        unless tile.picture_generating?
          tile.update!(picture_generating: true)
          GenerateTileImageJob.perform_later(tile.id)
        end
      end
    else
      # if it doesn't throw an error
      render json: { error: 'Tile not found' }, status: 404
    end
  end

  def get_tile
    x = params[:x].to_i
    y = params[:y].to_i

    tile = @current_game.tiles.find_by(x_position: x, y_position: y)
    if tile
      # If tile has no generated content, generate it
      if isGenerated(tile)
        # Update the tile with the generated content
        ai_generated_content = generate_tile_text(tile)
        tile.update!(
          scene_description: ai_generated_content[:scene_description],
          treasure_description: ai_generated_content[:treasure_description],
          monster_description: ai_generated_content[:monster_description],
          monster_level: ai_generated_content[:monster_level]
        )
      end

      render json: {
        x: tile.x_position,
        y: tile.y_position,
        biome: tile.biome,
        scene_description: tile.scene_description,
        treasure_description: tile.treasure_description,
        monster_description: tile.monster_description,
        monster_level: tile.monster_level
      }
    else
      render json: { error: 'Tile not found' }, status: 404
    end
  end

  def generate_tile_text(tile)
    # generate main tile properties
    puts prompts.keys.inspect
    inst_prompt = prompts['tile_instruction_prompt'] % { :biome => BIOMES[tile.biome] }
    response = OpenAIService.generate_content(
      "gpt-4o-mini",
      prompts['tile_system_prompt'],
      inst_prompt
    )
    parsed_response = JSON.parse(response, symbolize_names: true) rescue {}


    # Extract monster data
    monster_desc = parsed_response.dig(:monster, :description) || "Default monster description"

    # Calculate player strength
    player_level = @current_character.level
    player_items = @current_character.items.order(level: :desc).limit(3) # top 3 items
    if player_items.any?
      player_strength = player_level + player_items.sum(:level)
    else
      player_strength = player_level # no items
    end


    #Calculate Monster strength
    monster_levels = {
      easy: (player_strength / 2.0).ceil,
      medium: player_strength,
      hard: (player_strength * 2),
      boss: (player_strength * 5)
    }

    monster_levels.each do |difficulty, level|
      random_factor = rand((level * 0.1).to_i + 1) # Random up to 10% of the level
      monster_levels[difficulty] = [level + random_factor, 1].max
    end

    difficulty_weights = {
      easy: 20,
      medium: 50,
      hard: 20,
      boss: 10
    }
    weighted_difficulties = difficulty_weights.flat_map { |difficulty, weight| [difficulty] * weight }
    selected_difficulty = weighted_difficulties.sample

    # Use the selected difficulty to calculate monster level
    monster_level = monster_levels[selected_difficulty]


    # Custom loot logic
    roll = rand(100)
    treasure_description =
      if roll < 10
        generate_item()
      elsif roll < 80
        shards = rand(10..100)
        "Shards: #{shards}"
      else
        nil
      end

    {
      scene_description: parsed_response.dig(:landscape, :description) || "Default scene description",
      treasure_description: treasure_description,
      monster_description: monster_desc,
      monster_level: monster_level
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
        item_info = generate_item_details(treasure)

        # Ensure we have a character_id to attach this item to.
        character = @current_user.characters.find_by(game_id: @current_game.id)
        if character.nil?
          render json: { error: "No character found to assign item to." }, status: 420
          return
        end

        # Create a new item record in the items table with item_type instead of type
        Item.create!(
          name: item_info[:name],
          item_type: item_info[:item_type],
          description: item_info[:description],
          level: item_info[:level],
          character_id: character.id
        )
      end

      tile.update!(treasure_description: nil)
      render json: { success: true, tile: tile }
    else
      render json: {
        message: "Too late! This treasure is gone.",
        result: "no_loot",
        tile: tile,
      }, status: 420
    end
  end

  def fight_monster
    x = params[:x].to_i
    y = params[:y].to_i

    tile = @current_game.tiles.find_by(x_position: x, y_position: y)
    if tile && tile.monster_description.present?
      monster_level = tile.monster_level

      # Get the current character for the user in this game
      character = current_user.characters.find_by(game_id: @current_game.id)
      return render json: { error: "Character not found." }, status: 404 unless character

      # Calculate player strength
      player_level = character.level
      player_items = character.items.order(level: :desc).limit(3) # top 3 items
      if player_items.any?
        player_strength = player_level + player_items.sum(:level)
      else
        player_strength = player_level # no items
      end

      total = player_strength + monster_level
      if total == 0
        total = 1
      end
      player_odds = (player_strength.to_f / total) * 100.0
      # monster_odds = (monster_level.to_f / total) * 100.0 # Not strictly needed, but for clarity

      roll = rand(1..100)
      puts "Combat roll: #{roll}, Player odds: #{player_odds}, Player Strength: #{player_strength}, Monster Level: #{monster_level}"

      if roll <= player_odds
        # Player wins
        # Monster is slain
        tile.update!(monster_description: nil)
        tile.update!(monster_level: nil)
        character.update!(level: character.level + 1)

        if character.currentHealth < character.maxHealth
          character.update!(currentHealth: character.currentHealth + 1)
        end

        render json: {
          success: true,
          tile: tile,
          result: "player_win",
          character: {
            current_health: character.currentHealth,
            max_health: character.maxHealth,
            level: character.level
          },
          odds: player_odds,
        }

      else
        # Monster wins
        # Player loses 1 health
        new_health = character.currentHealth - 1
        character.update!(currentHealth: new_health)

        # Check if player's health is 0
        if character.currentHealth <= 0
          # Reset character's health and level
          character.items.destroy_all
          character.update!(maxHealth: 10)
          character.update!(currentHealth: character.maxHealth, level: 1)
          render json: {
            success: true,
            tile: tile,
            result: "player_died",
            message: "You died! All of your items have been lost, and your level is reset to 1.",
            character:
              {
                current_health: character.currentHealth,
                level: character.level,
                max_health: character.maxHealth,
              },
            odds: player_odds
          }
        else
          # Monster level increases by half the player's strength (rounded down)
          increase = (player_strength / 2).floor
          new_monster_level = monster_level + increase
          tile.update!(monster_level: new_monster_level)

          render json: {
            success: true,
            tile: tile,
            result: "monster_win",
            character: {
              current_health: character.currentHealth,
              max_health: character.maxHealth,
              level: character.level
            },
            odds: player_odds
          }
        end
      end
    else
      render json: {
        message: "This monster has already been slain!",
        result: "no_monster",
        tile: tile,
      }
    end
  end

  def regenerate_tile
    x = params[:x].to_i
    y = params[:y].to_i

    # Find the tile in the current game
    tile = @current_game.tiles.find_by(x_position: x, y_position: y)

    unless tile
      render json: { error: "Tile not found." }, status: :not_found
      return
    end

    # Check if the user/character has enough shards
    if @current_user.shard_amount < 250
      render json: { error: "You do not have enough shards. Please collect or buy more." }, status: :unprocessable_entity
      return
    end

    # Deduct 250 shards
    @current_user.shard_amount -= 250

    #chance to change biome just for fun
    colors = ['gray', 'green', 'yellow', 'blue']
    tile.biome = colors.sample

    ai_generated_content = generate_tile_text(tile)
    tile.update!(
      picture: ai_generated_content[:picture],
      scene_description: ai_generated_content[:scene_description],
      treasure_description: ai_generated_content[:treasure_description],
      monster_description: ai_generated_content[:monster_description],
      monster_level: ai_generated_content[:monster_level]
    )

    # Save both character and tile
    if @current_user.save && tile.save
      # Return the updated tile info in the same format as get_tile
      render json: {
        x: tile.x_position,
        y: tile.y_position,
        biome: tile.biome,
        picture: tile.picture,
        scene_description: tile.scene_description,
        treasure_description: tile.treasure_description,
        monster_description: tile.monster_description,
        monster_level: tile.monster_level,
      }
    else
      render json: { error: "Failed to regenerate tile." }, status: :internal_server_error
    end
  end

  def teleport_tile
    x = params[:x].to_i
    y = params[:y].to_i

    # Ensure the tile exists in the current game
    tile = @current_game.tiles.find_by(x_position: x, y_position: y)

    unless tile
      render json: { error: "Tile not found." }, status: :not_found
      return
    end

    character = current_user.characters.find_by(game_id: @current_game.id)
    unless character
      render json: { error: "Character not found." }, status: :unprocessable_entity
      return
    end

    # Check if user has enough shards
    if @current_user.shard_amount < 5
      render json: { error: "You do not have enough shards to teleport." }, status: :unprocessable_entity
      return
    end

    # Deduct shards and move character
    @current_user.shard_amount -= 5
    character.update!(x_position: x, y_position: y)
    @current_user.save!

    render json: {
      success: true,
      x: x,
      y: y,
      current_shards: @current_user.shard_amount,
      message: "Teleported to (#{x}, #{-y}) for 5 shards."
    }
  end

  private

  def prompts
    @prompts ||= YAML.load_file(Rails.root.join('config', 'prompts.yml'))
  end

  # small macro to test if ai content exists and is generated
  def isGenerated(tile)
    tile.picture.blank? && tile.scene_description.blank? && tile.treasure_description.blank? && tile.monster_description.blank?
  end

  def generate_item()
    used_names = @@generated_items.to_a
    name_list_str = used_names.empty? ? "[]" : used_names.map { |n| "\"#{n}\"" }.join(", ")

    3.times do
      item_response = OpenAIService.generate_content(
        "gpt-4o-mini",
        prompts['item_system_prompt'] % { :previous_item_names => name_list_str },
        prompts['item_instruction_prompt']
      )
      clean_response = item_response.gsub(/^```json\s*/, '').gsub(/```$/, '')

      begin
        item_data = JSON.parse(clean_response, symbolize_names: true)
        item_name = item_data[:name].strip
        unless @@generated_items.include?(item_name)
          @@generated_items.add(item_name)
          return "#{item_name}: #{item_data[:description]}"
        end
      rescue JSON::ParserError => e
        puts "Error parsing JSON for initial item: #{e.message}"
      end
    end
    "Unique Artifact of Mystery: A one-of-a-kind item you have never seen before."
  end

  def generate_item_details(item_string)
    # item_string format: "Name: Description"
    # Split only into two parts at most
    name, description = item_string.split(":", 2).map(&:strip)

    response = OpenAIService.generate_content(
      "gpt-4o-mini",
      prompts['item_details_prompt'] % { name: name, description: description },
      ""
    )
    clean_response = response.gsub(/^```json\s*/, '').gsub(/```$/, '')

    begin
      item_info = JSON.parse(clean_response, symbolize_names: true)
      # Validate that item_info has item_type. If not, fallback.
      if item_info[:item_type].nil? || !%w[weapon shield armor artifact].include?(item_info[:item_type])
        item_info = {
          name: name,
          item_type: "artifact",
          description: description
        }
      end

      # Add a randomly generated level between 1 and 20
      item_info[:level] = rand(1..20)
      item_info
    rescue JSON::ParserError => e
      puts "Error parsing JSON for item details: #{e.message}"
      # Fallback if parsing fails
      {
        name: name,
        item_type: "artifact",
        description: description,
        level: rand(1..20)
      }
    end
  end

end
