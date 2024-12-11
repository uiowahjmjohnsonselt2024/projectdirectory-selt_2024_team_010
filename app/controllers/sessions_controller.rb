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
    if user
      if user instance_of? ActiveRecord::RecordInvalid
        params[:message] = "Failed in creating the record;\n\n" + user.record.errors.full_messages.join("\n")
        redirect_to auth_failure_path
      else
        session[:session_token] = user.session_token
        flash[:notice] = "Logged in successfully"
        redirect_to dashboard_path
      end
    else
      redirect_to login_path
    end
  end

  def auth_failure
    flash[:warning] = "Authentication failed. :(\nReason: #{params[:message]}"
    redirect_to
  end
end