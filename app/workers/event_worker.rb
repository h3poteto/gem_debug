class EventWorker
  include Shoryuken::Worker

  shoryuken_options queue: "default", auto_delete: true, body_parser: :json

  def perform(sqs_msg, message)
    puts "shryuken event"
  end
end
