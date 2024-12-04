require_relative 'app/services/openAIService'

# Load the API key from the .env file
require 'dotenv'
Dotenv.load

api_key = ENV['OPENAI_API_KEY']
if api_key.nil? || api_key.empty?
  puts "Error: OPENAI_API_KEY is not set in the .env file."
  exit
end

# Test the GameContentGenerator class
def test_game_content_generator(api_key)
  # Define the system prompt
  system_prompt = <<~PROMPT
    You are a creative generator for a video game project. I will give you specifications on what to generate (a text description of a monster, a treasure, or the landscape), and you will return your responses in json format as seen below. If my instructions have no mention of either monster, landscape, or loot, then do not return that section. Only return sections mentioned.
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

  # Define the instruction prompt
  instruction_prompt = "Give me a description for a monster and a treasure."

  # Initialize the generator
  generator = GameContentGenerator.new(api_key)

  # Call the generate_content method
  puts "Testing GameContentGenerator...\n\n"
  response = generator.generate_content("gpt-4", system_prompt, instruction_prompt)

  if response
    puts "Test Passed!"
    puts "Generated Content:\n#{response}"
  else
    puts "Test Failed: No response generated."
  end
end

# Run the test
test_game_content_generator(api_key)
