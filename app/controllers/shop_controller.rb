# frozen_string_literal: true
class ShopController< ApplicationController

  before_action :require_login, :get_current_game
  def index
    @shard_amount = current_user.shard_amount || 0
    @money_usd = current_user.money_usd || 0
  end

  def balance
    user = current_user
    render json: { shard_amount: user.shard_amount, money_usd: user.money_usd }
  end

  def purchase
    user = current_user
    begin
      quantity = Integer(params[:quantity])
    rescue ArgumentError
      render json: { error: "Quantity must be an integer." }, status: 400
      return
    end
    cost = params[:cost].to_f

    if quantity <= 0 || cost <= 0
      render json: { error: "Invalid quantity or cost." }, status: 400
      return
    end

    if user.money_usd < cost
      render json: { error: "Insufficient balance." }, status: 400
      return
    end

    # Update the user's balance and shards
    user.money_usd -= cost
    user.shard_amount += quantity
    if user.save
      render json: { shard_amount: user.shard_amount, money_usd: user.money_usd }, status: 200
    else
      Rails.logger.error("Failed to update user data: #{user.errors.full_messages.join(', ')}")
      render json: { error: "Failed to update user data: #{user.errors.full_messages.join(', ')}" }, status: 500
    end
  end



  def payment
    currency = params[:currency]
    amount = params[:amount].to_f

    if amount <= 0
      render json: { error: "Invalid amount." }, status: 400
      return
    end

    # Get the current user
    user = current_user

    Payment.create(money_usd: amount, currency: currency, user_id: user.id)

    # Add the amount to the user's USD balance
    user.money_usd += amount

    if user.save
      render json: { money_usd: user.money_usd }, status: 200
    else
      Rails.logger.error("Failed to update user data: #{user.errors.full_messages.join(', ')}")
      render json: { error: "Failed to update user data: #{user.errors.full_messages.join(', ')}" }, status: 500
    end
  end

  def payment_history
    @payments = current_user.payments.order(created_at: :desc)

    respond_to do |format|
      format.json {render json: @payments}
    end
  end

end