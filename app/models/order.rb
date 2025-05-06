class Order < ApplicationRecord
  after_create :publish

  def publish
    KafkaProducer.publish("order-events", order_event_payload)
  rescue Kafka::Error => e
    Rails.logger.error "Failed to publish order event: #{e.message}"
  end

  def order_event_payload
    {
      event: "order.placed",
      user_email: user_email,
      data: {
        order_id: id,
        user_id: user_id,
        items: items
      }
    }.to_json
  end
end
