class SessionsController < ApplicationController
  before_action :current_user, only: [:destroy]
  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user != nil and user.authenticate(params[:password])
      create_session_token user
      flash[:notice] = "Logged in successfully"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    session[:session_token] = nil
    @current_user&.session&.destroy
    @current_user = nil
    flash[:notice] = "Logged out successfully"
    redirect_to welcome_path
  end

  def auth_success
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth)
    if user.nil?
      return auth_failure "Oauth login failed; please create an account or login normally."
    else
      if user.instance_of? ActiveRecord::RecordInvalid
        return auth_failure "Failed in creating the record. Please try again."
      elsif user.instance_of? NameError
        return auth_failure "You are attempting to authenticate with an email already registered; register normally with another email, or log in normally with the email assigned to your GitHub account."
      else
        create_session_token user
        flash[:notice] = "Logged in successfully"
        redirect_to dashboard_path
      end
    end
  end

  def auth_failure(reason)
    flash[:warning] = "Authentication failed. :(\nReason: #{reason}"
    redirect_to welcome_path
  end
end
