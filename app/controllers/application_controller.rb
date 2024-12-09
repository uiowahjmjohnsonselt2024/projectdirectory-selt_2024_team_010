class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?, :is_admin?

  def current_user
    @current_user ||= User.joins(:session).find_by(sessions: { session_token: session[:session_token] }) if session[:session_token]
  end

  def logged_in?
    current_user.present?
  end

  def is_admin?
    current_user&.isAdmin?
  end

  private

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to welcome_path
    end
  end

  def require_admin
    unless is_admin?
      flash[:alert] = "You must be an admin to access this section"
      redirect_to dashboard_path
    end
  end

  def create_session_token(user)
    user.create_session!(session_token: Session.create_session_token)
    session[:session_token] = user.session.session_token
  end

  def get_games_list
    @games = @current_user.games
  end

  def get_current_game
    if @current_user.recent_character.nil?
      @current_game = nil
      @current_character = nil
    else
      # Note: recent_character has no protections on it, we must implement those,
      # i.e. make sure it references a character that belongs to this user!
      @current_character = @current_user.characters.find_by_id(@current_user.recent_character)
      @current_game = @current_character.game
    end
  end
end
