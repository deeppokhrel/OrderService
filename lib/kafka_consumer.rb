class KafkaConsumer
  def initialize(topic)
    @kafka = Kafka.new([ ENV["KAFKA_BROKERS"] ])
    @topic = topic
  end

  def consume(&block)
    @kafka.each_message(topic: @topic) do |message|
      block.call(message)
    end
  end
end
