require 'typhoeus'
require 'json'

class LineMessenger
  BASE_URL = 'https://api.line.me'

  def initialize
    @headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV['LINE_CHANNEL_ACCESS_TOKEN']}"
    }
  end

  def push_message(user_id, message)
    body = {
      to: user_id,
      messages: [
        {
          type: 'text',
          text: message
        }
      ]
    }

    response = Typhoeus::Request.post(
      "#{BASE_URL}/v2/bot/message/push",
      headers: @headers,
      body: body.to_json
    )

  end
end
