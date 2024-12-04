# frozen_string_literal: true
class GamesController < ApplicationController
  before_action :require_login, :get_games_list
  def index
    @games = @current_user.games
  end

  def new

  end

  def create
    new_game = @current_user.games.create(name: params[:server_name], owner_id: @current_user.id)
    if new_game.save
      flash[:notice] = 'Game successfully created'
      @current_user.characters.create(game_id: params[:id])
      redirect_to games_path
    else
      if new_game.errors.include?(:name)
        flash[:alert] = 'Name already used'
      else
        flash[:alert] = 'Server creation failed'
      end
      redirect_to new_game_path
      # This will be conditional based on why a game couldn't be created, could be because the title was already used,
      # or could be because they hit a limit on how many games they can have at once, etc.
    end
  end

  def list
    if params[:server_name]
      @search = params[:server_name]
      games = Game.arel_table
      @found_games = Game.where(games[:name].matches("%#{@search}%"))
    end
  end

  def add
    new_character = @current_user.characters.create(game_id: params[:id])
    if new_character.errors.include?(:user_id)
      flash[:notice] = 'Already added game'
    end
    redirect_to games_path
  end

  def show
    game = Game.find(params[:id])
    @current_user.update!(recent_character: @current_user.characters.find_by(game_id: game.id).id)
    get_current_game

    base_biome = 'yellow'
    @cell_colors = {}

    # Step 1: Base Layer
    (-3..3).each do |x|
      (-3..3).each do |y|
        @cell_colors[[x, y]] = base_biome
      end
    end

    # Step 2: Seed Biomes
    seed_biomes(['blue', 'gray', 'green'], @cell_colors)

    # Step 3: Spread Biomes
    spread_biomes(@cell_colors)

    # Step 4: Post-Processing
    smooth_grid(@cell_colors)
  end

  private

  def seed_biomes(biomes, cell_colors)
    biomes.each do |biome|
      3.times do
        x, y = rand(-3..3), rand(-3..3)
        cell_colors[[x, y]] = biome
      end
    end
  end

  def spread_biomes(cell_colors)
    (1..3).each do |_|
      new_colors = cell_colors.dup
      (-3..3).each do |x|
        (-3..3).each do |y|
          adjacent_colors = [
            cell_colors[[x - 1, y]],
            cell_colors[[x + 1, y]],
            cell_colors[[x, y - 1]],
            cell_colors[[x, y + 1]]
          ].compact

          case cell_colors[[x, y]]
          when 'yellow'
            new_colors[[x, y]] = 'blue' if adjacent_colors.include?('blue') && rand < 0.3
            new_colors[[x, y]] = 'green' if adjacent_colors.include?('green') && rand < 0.5
          when 'green'
            new_colors[[x, y]] = 'gray' if adjacent_colors.include?('gray') && rand < 0.4
          end
        end
      end
      cell_colors.merge!(new_colors)
    end
  end

  def smooth_grid(cell_colors)
    (-3..3).each do |x|
      (-3..3).each do |y|
        adjacent_colors = [
          cell_colors[[x - 1, y]],
          cell_colors[[x + 1, y]],
          cell_colors[[x, y - 1]],
          cell_colors[[x, y + 1]]
        ].compact

        # Remove isolated tiles
        if adjacent_colors.count(cell_colors[[x, y]]) < 2
          cell_colors[[x, y]] = adjacent_colors.group_by(&:itself).max_by { |_k, v| v.size }&.first || 'yellow'
        end
      end
    end
  end

end