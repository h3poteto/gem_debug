#  ShoryukenとSQSのつなぎ込みをする前に、SQS側にキューが存在している必要がある
sqs_client = Aws::SQS::Client.new(
  endpoint: ENV["SQS_ENDPOINT"],
  secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
  access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  region: ENV["AWS_REGION"],
  raise_response_errors: false
)
queues = sqs_client.list_queues
# queues.queue_urlsは
# "http://0.0.0.0:4568/crowdworks-dev-copy-check-queue"
# というstringが返ってくるので、比較のためにpathを抜き出す
unless queues.queue_urls.map{|q| URI.parse(q).path }.any?{|p| /.*event/ =~ p }
  new_queue = sqs_client.create_queue(queue_name: "event")
  if new_queue
    Rails.logger.info "#{new_queue.queue_url}を作成しました"
  else
    Rails.logger.error "#{sqs_client.config.endpoint}/eventの作成に失敗しました"
  end
end
# Shoryuken::EnvironmentLoader.load(config_file: "config/shoryuken.yml", logfile: "log/shoryuken.log")

Shoryuken.configure_server do |config|
  config.aws = {
    sqs_endpoint: ENV["SQS_ENDPOINT"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    region: ENV["AWS_REGION"]
  }
end

Shoryuken.configure_client do |config|
  config.aws = {
    sqs_endpoint: ENV["SQS_ENDPOINT"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    region: ENV["AWS_REGION"]
  }
end
