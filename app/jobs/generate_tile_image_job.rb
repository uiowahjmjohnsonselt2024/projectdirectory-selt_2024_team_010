# we're using a background job to generate images, since they could take a significant amount of time to arrive.
class GenerateTileImageJob < ActiveJob::Base
  queue_as :default

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
