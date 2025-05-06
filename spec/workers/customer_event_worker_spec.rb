# spec/workers/customer_event_worker_spec.rb
require 'rails_helper'

RSpec.describe CustomerEventWorker do
  let(:kafka_consumer) { instance_double('KafkaConsumer') }
  let(:message) { instance_double('Kafka::FetchedMessage', value: payload.to_json) }

  let(:user_attributes) do
    {
      email: "test@example.com",
      name: "Test User"
    }
  end
  let(:user) { User.create!(user_attributes) }

  before do
    allow(KafkaConsumer).to receive(:new).with("customer-events").and_return(kafka_consumer)
    allow(kafka_consumer).to receive(:consume).and_yield(message)
  end

  describe '.start' do
    context 'when event_type is customer.created' do
      let(:payload) do
        {
          event_type: "customer.created",
          data: {
            email: "new@example.com",
            name: "New User"
          }
        }
      end

      it 'calls User.create_user with parsed event data' do
        expect(User).to receive(:create_user).with(hash_including(
          "event_type" => "customer.created",
          "data" => hash_including(
            "email" => "new@example.com",
            "name" => "New User"
          )
        ))
        described_class.start
      end
    end

    context 'when event_type is customer.updated' do
      let(:payload) do
        {
          event_type: "customer.updated",
          data: {
            email: "updated@example.com",
            name: "Updated Name"
          }
        }
      end

      it 'calls User.update_user with parsed event data' do
        expect(User).to receive(:update_user).with({ "data"=>{ "email"=>"updated@example.com", "name"=>"Updated Name" }, "event_type"=>"customer.updated" })
        described_class.start
      end
    end

    context 'when event_type is customer.destroyed' do
      let(:payload) do
        {
          event_type: "customer.destroyed",
          data: {
            "email" => "new@example.com",
            "name" => "New User"
          }
        }
      end

      it 'calls User.destroy_user with parsed event data' do
        expect(User).to receive(:destroy_user).with(hash_including(
          "event_type" => "customer.destroyed",
          "data" => hash_including(
            "email" => "new@example.com",
            "name" => "New User"
          )
        ))
        described_class.start
      end
    end

    context 'when event_type is unknown' do
      let(:payload) { { event_type: "unknown.event" } }

      it 'logs unknown event message' do
        expect(Rails.logger).to receive(:info).with("Unknown event type: unknown.event")
        described_class.start
      end

      it 'does not call any User methods' do
        expect(User).not_to receive(:create_user)
        expect(User).not_to receive(:update_user)
        expect(User).not_to receive(:destroy_user)
        described_class.start
      end
    end

    context 'when user operation fails' do
      let(:payload) do
        {
          event_type: "customer.created",
          data: { email: "new@example.com" }
        }
      end

      before do
        allow(User).to receive(:create_user).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'logs the error without crashing' do
        expect(Rails.logger).to receive(:error).with(/Failed to process customer event/)
        expect { described_class.start }.not_to raise_error
      end
    end
  end
end
