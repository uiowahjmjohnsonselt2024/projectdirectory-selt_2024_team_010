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

end