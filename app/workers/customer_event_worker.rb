class CustomerEventWorker
  def self.start
    consumer = KafkaConsumer.new("customer-events")
    consumer.consume do |message|
      begin
        event = JSON.parse(message.value)
        case event["event_type"]
        when "customer.created"
          User.create_user(event)
        when "customer.updated"
          User.update_user(event)
        when "customer.destroyed"
          User.destroy_user(event)
        else
          Rails.logger.info "Unknown event type: #{event['event_type']}"
        end
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse message: #{e.message}"
      rescue => e
        Rails.logger.error "Failed to process customer event: #{e.message}"
      end
    end
  end
end
