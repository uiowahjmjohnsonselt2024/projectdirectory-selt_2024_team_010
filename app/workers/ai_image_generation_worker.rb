class AiImageGenerationWorker
  include Sidekiq::Worker

  def prompts
    @prompts ||= YAML.load_file(Rails.root.join('config', 'prompts.yml'))
  end

  def perform(tile_id)
    tile = Tile.find(tile_id) # @todo there may be a better way of doing this

    prompt = prompts["image_prompt"] % { scene_description: tile.scene_description }
    image = OpenAIService.generate_image(prompt)
    tile.update!(
      picture: image,
      picture_generating: false
    )
  end
end
