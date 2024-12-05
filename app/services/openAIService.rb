# create class to house it
# give api key
# function to
# system prompt string: You are a creative generator for a video game project. I will give you
#                       specifications on what to generate (a text description of a monster, a treasure, or
#                       the landscape), and you will return your responses in json format as seen below. If my
#                       instructions have no mention of either monster, landscape, or loot, then do not return
#                       anything for those sections. Only return the specified information.
# {
#   "monster": {
#     "description": "[Monster description placeholder]",
#     "level": 0
#   },
#   "landscape": {
#     "description": "[Landscape description placeholder]"
#   },
#   "loot": {
#     "name": "[Loot name placeholder]",
#     "rarity": "[Loot rarity placeholder]",
#     "level": 0
#   }
# }
#
# instruction string:
#     EX: Give me a description for a monster.
#     EX: Give me a description for a treasure.
#     EX: Give me a description for a biome and a monster whose level is 15.


require 'openai'
require 'dotenv'

Dotenv.load

# Ensure API key is loaded
api_key = ENV['OPENAI_API_KEY']
if api_key.nil? || api_key.empty?
  puts "Error: OPENAI_API_KEY is not set in the .env file."
  exit
end

class GameContentGenerator
  def initialize(api_key)
    @client = OpenAI::Client.new(access_token: api_key)
  end

  # Method to generate content based on the model, system prompt, and instruction
  def generate_content(model, system_prompt, instruction_prompt)

    # Messages array with system prompt and instruction prompt
    messages = [
      { role: "system", content: system_prompt },
      { role: "user", content: instruction_prompt }
    ]

    # Call the OpenAI API
    response = @client.chat(
      parameters: {
        model: model,
        messages: messages,
        temperature: 0.7
      }
    )

    # Parse and return the assistant's response
    response.dig("choices", 0, "message", "content")
  end
end

