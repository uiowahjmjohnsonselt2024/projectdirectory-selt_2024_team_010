require_relative 'app/services/openAIService'

# Load the API key from the .env file
require 'dotenv'
Dotenv.load

api_key = ENV['OPENAI_API_KEY']
if api_key.nil? || api_key.empty?
  puts "Error: OPENAI_API_KEY is not set in the .env file."
  exit
end

# Test the DALL-E Image Generator
def test_dalle_image_generator(api_key)
  # Define the prompt for image generation
  image_prompt = "A fantasy landscape with a towering crystal mountain surrounded by glowing trees and floating islands."

  # Initialize the OpenAI client
  client = OpenAI::Client.new(access_token: api_key)

  begin
    # Call the OpenAI API for image generation
    puts "Testing DALL-E Image Generator...\n\n"
    response = client.images.generate(
      parameters: {
        prompt: image_prompt,
        n: 1, # Number of images to generate
        size: "1024x1024" # Size of the image
      }
    )

    # Extract and display the URL of the generated image
    if response && response["data"] && response["data"].any?
      image_url = response["data"].first["url"]
      puts "Test Passed!"
      puts "Generated Image URL:\n#{image_url}"
    else
      puts "Test Failed: No image generated."
    end
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end

# Run the test
test_dalle_image_generator(api_key)
