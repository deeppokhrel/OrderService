# spec/models/order_spec.rb
require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order_attributes) do
    {
      user_id: 1,
      user_email: 'test@example.com',
      items: [ { sku: 'ITEM123', quantity: 2 } ]
    }
  end

  describe 'callbacks' do
    describe '#publish' do
      let(:kafka_producer) { class_double('KafkaProducer') }

      before do
        stub_const('KafkaProducer', kafka_producer)
        allow(kafka_producer).to receive(:publish)
      end

      it 'publishes an event after creation' do
        expect(KafkaProducer).to receive(:publish).with("order-events", instance_of(String))
        Order.create!(order_attributes)
      end

      it 'publishes the correct payload structure' do
        order = Order.create!(order_attributes)
        expected_payload = {
          event: "order.placed",
          user_email: order.user_email,
          data: {
            order_id: order.id,
            user_id: order.user_id,
            items: order.items
          }
        }.to_json

        expect(KafkaProducer).to have_received(:publish).with(
          "order-events",
          expected_payload
        )
      end
    end
  end

  describe '#order_event_payload' do
    let(:order) { Order.new(order_attributes) }

    it 'returns valid JSON' do
      expect { JSON.parse(order.order_event_payload) }.not_to raise_error
    end

    it 'includes all required fields' do
      payload = JSON.parse(order.order_event_payload)
      expect(payload).to include(
        'event' => 'order.placed',
        'user_email' => order.user_email,
        'data' => a_hash_including(
          'order_id' => order.id,
          'user_id' => order.user_id,
          'items' => order.items
        )
      )
    end

    context 'when items are empty' do
      before { order.items = [] }

      it 'still generates valid payload' do
        payload = JSON.parse(order.order_event_payload)
        expect(payload['data']['items']).to eq([])
      end
    end
  end

  describe 'error handling' do
    let(:kafka_producer) { class_double('KafkaProducer') }

    before do
      stub_const('KafkaProducer', kafka_producer)
      allow(kafka_producer).to receive(:publish).and_raise(Kafka::Error)
    end

    it 'does not prevent order creation when Kafka fails' do
      expect {
        Order.create!(order_attributes)
      }.to change(Order, :count).by(1)
    end

    it 'logs the error' do
      expect(Rails.logger).to receive(:error).with(/Failed to publish order event/)
      Order.create!(order_attributes)
    end
  end
end
