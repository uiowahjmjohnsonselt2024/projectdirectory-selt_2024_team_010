require 'openai'
require 'openAIService'

class GameshopController < ApplicationController
  def index

  end
  def update_shards
    # Permit and retrieve the shard_amount parameter
    shard_params = params.require(:shard).permit(:shard_amount)
    shard_amount = shard_params[:shard_amount].to_f

    # Calculate the new shard amount
    new_shard_amount = current_user.shard_amount - shard_amount

    # Prevent shard_amount from going negative
    if new_shard_amount < 0
      render json: { error: "Insufficient shards. Cannot deduct #{-shard_amount} shards." }, status: :unprocessable_entity
      return
    end

    # Update the user's shards
    if current_user.update(shard_amount: new_shard_amount)
      render json: { success: true, shard_amount: current_user.shard_amount }, status: :ok
    else
      render json: { error: "Failed to update shards." }, status: :internal_server_error
    end
  rescue ActionController::ParameterMissing
    render json: { error: "Missing shard parameters." }, status: :bad_request
  end
  def buy
    # check for if they have at least one character
    character = current_user.characters.first
    if character.nil?
      render json: { error: "No character found to assign item to." }, status: :bad_request
      return
    end

    item_params = params.require(:item).permit(:name, :description, :level, :category, :price)

    # Convert price to a numeric value (float or integer)
    price = item_params[:price].to_f

    # Check if user has enough shards
    if current_user.shard_amount < price
      render json: { error: "You do not have enough shards to purchase this item." }, status: :unprocessable_entity
      return
    end

    # Normalize category
    item_type_value = case item_params[:category].to_s.downcase
                      when "weapons" then "weapon"
                      when "armor" then "armor"
                      when "abilities" then "artifact"
                      else
                        render json: { error: "#{item_params[:category]} is not a valid category" }, status: :unprocessable_entity
                        return
                      end

    # Deduct price from user's shards
    current_user.update!(shard_amount: current_user.shard_amount - price)

    # Create the item
    item = Item.create!(
      name: item_params[:name],
      item_type: item_type_value,
      description: item_params[:description],
      level: rand(1..20),
      character_id: character.id
    )

    render json: { success: true, message: "Item purchased successfully!", item: item }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  def generate_items
    generator = OpenAIService.new

    system_prompt = <<~PROMPT
    You are a game item generator, specialized in creating unique items for a fantasy RPG.
    You generate items in a structured JSON format. Each item should have:
    - name (string)
    - category (string: Weapons, Armor, or Abilities)
    - price (integer or float)
    - description (string)
    Make sure the JSON is valid and includes an array of items.
  PROMPT

    instruction_prompt = <<~PROMPT
    Generate three items suitable for a level 5 player. Make sure that:
    - One item should have the category "Weapon".
    - One item should have the category "Armor".
    - One item should have the category "Abilities".
    Return only valid JSON with no additional commentary. The JSON should have an "items" key containing the array of items.
  PROMPT

    # Generate content
    generated_content = generator.generate_content("gpt-4o-mini", system_prompt, instruction_prompt)
    Rails.logger.debug "Generated Content from OpenAI: #{generated_content}"

    begin
      # Strip backticks if they are present
      if generated_content.start_with?("```json") && generated_content.end_with?("```")
        generated_content = generated_content.gsub(/\A```json\s*|\s*```\z/, "")
      end

      parsed_content = JSON.parse(generated_content)
      Rails.logger.debug "Parsed Content: #{parsed_content.inspect}"

      # Determine if parsed_content is a Hash or Array
      if parsed_content.is_a?(Hash) && parsed_content["items"]
        items = parsed_content["items"]
      elsif parsed_content.is_a?(Array)
        items = parsed_content
      else
        Rails.logger.error "Unexpected JSON structure: #{parsed_content.inspect}"
        items = []
      end

      # Normalize categories
      items.each do |item|
        item["category"] = case item["category"].to_s.downcase
                           when "weapon", "weapons" then "Weapon"
                           when "armor" then "Armor"
                           when "abilities", "ability" then "Abilities"
                           else item["category"]
                           end
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse JSON: #{e.message} | Content: #{generated_content}"
      items = []
    end

    respond_to do |format|
      format.json { render json: { items: items } }
      format.html { @items = items }
    end
  end

end