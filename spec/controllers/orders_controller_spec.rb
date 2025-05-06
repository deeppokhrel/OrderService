# spec/controllers/orders_controller_spec.rb
require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        order: {
          user_id: 1,
          user_email: 'user@example.com',
          items: [
            { sku: 'ITEM123', quantity: "2" },
            { sku: 'ITEM456', quantity: "1" }
          ]
        }
      }
    end

    let(:invalid_attributes) do
      {
        order: {
          user_email: 'user@example.com',
          # missing user_id
          items: []
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new Order' do
        expect {
          post :create, params: valid_attributes
        }.to change(Order, :count).by(1)
      end

      it 'returns a 201 created status' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end

      it 'returns success message' do
        post :create, params: valid_attributes
        expect(JSON.parse(response.body)).to eq({ 'status' => 'order placed' })
      end

      it 'persists all order attributes' do
        post :create, params: valid_attributes
        order = Order.last
        expect(order.user_id).to eq(1)
        expect(order.user_email).to eq('user@example.com')
        expect(order.items).to eq([ { "sku"=>"ITEM123", "quantity"=>"2" }, { "sku"=>"ITEM456", "quantity"=>"1" } ])
      end
    end
  end
end
