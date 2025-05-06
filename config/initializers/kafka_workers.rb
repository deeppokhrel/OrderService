Rails.application.config.after_initialize do
  Thread.new { CustomerEventWorker.start }
end
