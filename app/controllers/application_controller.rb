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
end
