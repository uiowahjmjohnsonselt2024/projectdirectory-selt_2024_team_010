# we're using a background job to generate images, since they could take a significant amount of time to arrive.
class GenerateTileImageJob < ActiveJob::Base
  queue_as :default
  def perform(tile_id)
    tile = Tile.find(tile_id)
    image = generate_tile_image(tile) # Call the method to generate the image
    tile.update!(
      picture: image,
      )
  end
end
   