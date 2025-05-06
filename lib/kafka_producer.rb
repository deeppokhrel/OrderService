require "kafka"

class KafkaProducer
  def self.publish(topic, message)
    kafka = Kafka.new([ ENV["KAFKA_BROKERS"] ])
    kafka.deliver_message(message, topic: topic)
  end
end
