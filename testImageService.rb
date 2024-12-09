require_relative 'app/services/game_content_generator'
require 'dotenv'
require 'open-uri'
require 'base64'

Dotenv.load

api_key = ENV['OPENAI_API_KEY']
if api_key.nil? || api_key.empty?
  puts "Error: OPENAI_API_KEY is not set in the .env file."
  exit
end

# Test the DALL-E Image Generator with Base64 Encoding and Save to File
def test_dalle_image_generator_save_base64(api_key)
  # Define the prompt for image generation
  image_prompt = "A fantasy landscape with a towering crystal mountain surrounded by glowing trees and floating islands."

  # Initialize the OpenAI client
  client = OpenAI::Client.new(access_token: api_key)

  begin
    # Call the OpenAI API for image generation with Base64 response format
    puts "Testing DALL-E Image Generator with Base64 Encoding and Saving to File...\n\n"
    response = client.images.generate(
      parameters: {
        prompt: image_prompt,
        n: 1, # Number of images to generate
        size: "256x256", # Size of the image
        response_format: "b64_json" # Request Base64-encoded image data
      }
    )

    # Extract the Base64-encoded image data
    if response && response["data"] && response["data"].any?
      base64_image = response["data"].first["b64_json"]
      puts "Image successfully generated and encoded in Base64."

      # Save the Base64 string to a file
      output_file = "generated_image_base64.txt"
      File.open(output_file, "w") do |file|
        file.write(base64_image)
      end

      puts "Test Passed!"
      puts "Base64 Encoded Image saved to file: #{output_file}"

      # Return the output file name
      output_file
    else
      puts "Test Failed: No image generated."
      nil
    end
  rescue StandardError => e
    puts "Error: #{e.message}"
    nil
  end
end

# Run the test
test_dalle_image_generator_save_base64(api_key)
