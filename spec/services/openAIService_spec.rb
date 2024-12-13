require 'rails_helper'
require 'openAIService'

RSpec.describe OpenAIService, type: :service do
  before do
    # Mock the environment variable for the API key
    allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return('test_api_key')
  end

  describe '#initialize' do
    it 'initializes the client with the API key' do
      service = OpenAIService.new
      client = service.instance_variable_get(:@client)
      expect(client).to be_an_instance_of(OpenAI::Client)
    end
  end

  describe '.new' do
    context 'when OPENAI_API_KEY is not set' do
      before do
        allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
      end
    end
  end

  describe '#generate_content' do
    let(:service) { OpenAIService.new }
    let(:model) { 'gpt-3.5-turbo' }
    let(:system_prompt) { 'You are a helpful assistant.' }
    let(:instruction_prompt) { 'Tell me a joke.' }

    context 'when API responds correctly' do
      let(:mock_response) do
        {
          'choices' => [
            {
              'message' => {
                'content' => 'Why did the chicken cross the road? To get to the other side!'
              }
            }
          ]
        }
      end

      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(mock_response)
      end

      it 'returns the content from the API response' do
        response = service.generate_content(model, system_prompt, instruction_prompt)
        expect(response).to eq('Why did the chicken cross the road? To get to the other side!')
      end

      it 'calls the OpenAI API with correct parameters' do
        expect_any_instance_of(OpenAI::Client).to receive(:chat).with(
          parameters: {
            model: model,
            messages: [
              { role: 'system', content: system_prompt },
              { role: 'user', content: instruction_prompt }
            ],
            temperature: 0.7
          }
        )
        service.generate_content(model, system_prompt, instruction_prompt)
      end
    end

    context 'when the API response is nil' do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(nil)
      end

      it 'returns nil' do
        response = service.generate_content(model, system_prompt, instruction_prompt)
        expect(response).to be_nil
      end
    end

    context 'when the API response does not include choices' do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return({})
      end

      it 'returns nil' do
        response = service.generate_content(model, system_prompt, instruction_prompt)
        expect(response).to be_nil
      end
    end

    context 'when the API response includes choices but no message content' do
      let(:mock_response) do
        {
          'choices' => [
            {
              'message' => {}
            }
          ]
        }
      end

      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(mock_response)
      end

      it 'returns nil' do
        response = service.generate_content(model, system_prompt, instruction_prompt)
        expect(response).to be_nil
      end
    end

    context 'when an exception occurs during API call' do
      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_raise(StandardError, 'API error')
      end

      it 'raises an exception with the error message' do
        expect do
          service.generate_content(model, system_prompt, instruction_prompt)
        end.to raise_error(StandardError, 'API error')
      end
    end

    context 'when using a different model' do
      let(:mock_response) do
        {
          'choices' => [
            {
              'message' => {
                'content' => 'This is a response from a different model.'
              }
            }
          ]
        }
      end

      before do
        allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(mock_response)
      end

      it 'returns the content for the specified model' do
        response = service.generate_content('text-davinci-003', system_prompt, instruction_prompt)
        expect(response).to eq('This is a response from a different model.')
      end
    end
  end
end
