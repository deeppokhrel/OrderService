# config/initializers/kafka.rb
RETRY_COUNT = 3
RETRY_DELAY = 5 # seconds

begin
  retries ||= 0
  kafka = Kafka.new(
    seed_brokers: ENV["KAFKA_BROKERS"] || "localhost:9092",
    connect_timeout: 10,
    socket_timeout: 10
  )
  Rails.application.config.kafka = kafka
rescue Kafka::ConnectionError => e
  if (retries += 1) <= RETRY_COUNT
    sleep RETRY_DELAY
    retry
  else
    raise "Failed to connect to Kafka after #{RETRY_COUNT} retries: #{e.message}"
  end
end
