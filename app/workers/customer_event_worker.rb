class CustomerEventWorker
  def self.start
    consumer = KafkaConsumer.new("customer-events")
    consumer.consume do |message|
      event = JSON.parse(message.value)
      case event["event_type"]
      when "customer.created"
        User.create_user(event)
      when "customer.updated"
        User.update_user(event)
      when "customer.destroy"
        User.destroy_user(event)
      else
        puts "Unknown event."
      end
    end
  end
end
