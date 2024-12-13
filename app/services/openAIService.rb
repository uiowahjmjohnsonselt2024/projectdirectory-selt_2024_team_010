require 'openai'
require 'dotenv' if Rails.env.development? || Rails.env.test?

Dotenv.load if Rails.env.development? || Rails.env.test?

# Ensure API key is loaded


class OpenAIService
  @@api_key = ENV['OPENAI_API_KEY']
  if @@api_key.nil? || @@api_key.empty?
    puts "Error: OPENAI_API_KEY is not set in the .env file."
    exit
  end

  def initialize
    @client = OpenAI::Client.new(access_token: @@api_key)
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

    # Return nil if the response is nil or doesn't include the expected structure
    return nil unless response && response.dig("choices", 0, "message", "content")

    # Parse and return the assistant's response
    response.dig("choices", 0, "message", "content")
  end

end

