# frozen_string_literal: true
class ShopController< ApplicationController
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
    quantity = params[:quantity].to_i
    cost = params[:cost].to_f
    currency = params[:currency]

    if quantity <= 0 || cost <= 0
      render json: { error: "Invalid quantity or cost." }, status: 400
      return
    end

    # handle currency conversion if necessary
    if currency != "USD"
      conversion_rate = get_conversion_rate(currency)
      cost /= conversion_rate
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

  private

  def get_conversion_rate(currency)
    # need to implement properly
    rates = { "USD" => 1.0}
    rates[currency] || 1.0 # Default to 1.0 if currency is unknown
  end

end