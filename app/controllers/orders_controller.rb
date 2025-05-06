class OrdersController < ApplicationController
  def create
    order = Order.create!(order_params)

    render json: { status: "order placed" }, status: :created
  end

  private

  def order_params
    params.require(:order).permit(:user_id, :user_email, items: [ :sku, :quantity ])
  end
end
