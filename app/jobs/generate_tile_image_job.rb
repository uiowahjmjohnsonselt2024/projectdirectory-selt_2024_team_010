# we're using a background job to generate images, since they could take a significant amount of time to arrive.
class GenerateTileImageJob < ActiveJob::Base
  queue_as :default

  def prompts
    @prompts ||= YAML.load_file(Rails.root.join('config', 'prompts.yml'))
  end

  def perform(tile_id)
    tile = Tile.find(tile_id) # @todo there may be a better way of doing this

    #Rails.logger.info "Prompts loaded: #{prompts.inspect}"
    Rails.logger.info prompts["image_prompt"]
    Rails.logger.info "Tile scene_description: #{tile.scene_description.inspect}"

    prompt = prompts["image_prompt"] % { scene_description: tile.scene_description }
    image = GameContentGenerator.generate_image(prompt)
    tile.update!(
      picture: image,
    )
  end
end
   