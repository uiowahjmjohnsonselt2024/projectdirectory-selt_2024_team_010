require 'openai'
require 'dotenv'

Dotenv.load

# Load the API key from the .env file
api_key = ENV['OPENAI_API_KEY']
if api_key.nil? || api_key.empty?
  puts "Error: OPENAI_API_KEY is not set in the .env file."
  exit
end

# Initialize the OpenAI client
client = OpenAI::Client.new(access_token: api_key)

system_prompt = "You are a helpful assistant"

# Initialize the messages with the system prompt
messages = [{ role: "system", content: system_prompt }]

puts "\nChatGPT is ready. Type 'exit' to quit.\n\n"

# Chat loop
loop do
  print "You: "
  user_input = gets.chomp
  break if user_input.downcase == 'exit'

  # Add the user's message to the messages array
  messages << { role: "user", content: user_input }

  begin
    # Call the OpenAI API
    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: messages,
        temperature: 0.7
      }
    )

    # Get the assistant's response
    assistant_reply = response.dig("choices", 0, "message", "content")
    puts "ChatGPT: #{assistant_reply}"

    # Add the assistant's response to the messages array
    messages << { role: "assistant", content: assistant_reply }
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end

puts "\nGoodbye!"
