class GameshopController < ApplicationController
  def index

  end

  # Action to generate items using OpenAI and return them as JSON (or HTML)
  def generate_items
    # Initialize our content generator
    generator = GameContentGenerator.new(ENV['OPENAI_API_KEY'])

    # Define system and user instructions:
    # The system prompt sets the context of what the assistant is (an expert game item generator).
    system_prompt = <<~PROMPT
      You are a game item generator, specialized in creating unique items for a fantasy RPG.
      You generate items in a structured JSON format. Each item should have:
      - name (string)
      - category (string: Weapons, Armor, or Abilities)
      - price (integer or float)
      - description (string)
      - rarity (string: common, uncommon, rare, epic, legendary)
      Make sure the JSON is valid and includes an array of items.
    PROMPT

    # The user prompt could specify the number and type of items.
    # This is where you can dynamically change what you request.
    instruction_prompt = <<~PROMPT
      Generate three items suitable for a level 5 player. Make sure that:
      - One item should be a Weapon.
      - One item should be an Armor piece.
      - One item should be an Ability.
      Return only valid JSON with no additional commentary.
    PROMPT

    generated_content = generator.generate_content("gpt-3.5-turbo", system_prompt, instruction_prompt)

    # Attempt to parse the JSON that the model returns
    begin
      items = JSON.parse(generated_content)
    rescue JSON::ParserError
      # Handle invalid JSON from the model gracefully
      items = []
    end

    # Respond with JSON so that your front-end can dynamically load items
    respond_to do |format|
      format.json { render json: items }
      format.html { @items = items } # If you want to handle HTML rendering as well.
    end
  end
end
