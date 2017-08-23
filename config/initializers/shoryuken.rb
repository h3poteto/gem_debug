#  ShoryukenとSQSのつなぎ込みをする前に、SQS側にキューが存在している必要がある
sqs_client = Aws::SQS::Client.new(
  endpoint: ENV["SQS_ENDPOINT"],
  secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
  access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  region: ENV["AWS_REGION"],
  raise_response_errors: false
)
queues = sqs_client.list_queues
if queues.successful?
  YAML.load(ERB.new(IO.read(Rails.root.join("config/shoryuken.yml"))).result).
    deep_symbolize_keys[:queues].each do |shoryuken_queue, _priority|
    # queues.queue_urlsは
    # "http://0.0.0.0:4568/crowdworks-development-copy-check-queue"
    # というstringが返ってくるので、比較のためにpathを抜き出す
    unless queues.queue_urls.map{|q| URI.parse(q).path }.any?{|p| /.*#{shoryuken_queue}/ =~ p }
      new_queue = sqs_client.create_queue(queue_name: shoryuken_queue)
      if new_queue
        Rails.logger.info "#{new_queue.queue_url}を作成しました"
      else
        Rails.logger.error "#{sqs_client.config.endpoint}/#{shoryuken_queue}の作成に失敗しました"
      end
    end
  end
end

Shoryuken.configure_client do |config|
  config.sqs_client = Aws::SQS::Client.new(
    endpoint: ENV["SQS_ENDPOINT"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    region: ENV["AWS_REGION"],
    verify_checksums: false
  )
  config.sqs_client_receive_message_opts = {
    attribute_names: %(
      ApproximateReceiveCount
      SentTimestamp
    )
  }
end

Shoryuken.configure_server do |config|
  config.sqs_client = Aws::SQS::Client.new(
    endpoint: ENV["SQS_ENDPOINT"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    region: ENV["AWS_REGION"],
    verify_checksums: false
  )
end
