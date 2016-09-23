class EventWorker
  include Shoryuken::Worker

  shoryuken_options queue: "event", auto_delete: true

  def perform(sqs_msg, message)
    puts "shryuken event"
  end
end
