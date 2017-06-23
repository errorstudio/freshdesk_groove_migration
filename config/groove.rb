GROOVE_API = Her::API.new

class GrooveTokenAuth < Faraday::Middleware
  def call(env)
    env[:request_headers]["Authorization"] = "Bearer #{$credentials[:groove]}"
    @app.call(env)
  end
end

class GrooveParser < Faraday::Response::Middleware
  def on_complete(env)
    begin
      json = MultiJson.load(env[:body], symbolize_keys: true)
    rescue
        json = {
          data: nil,
          errors: [env[:status], env[:reason_phrase]],
          metadata: nil
        }
    end
    env[:body] = {
      data: json.values.first,
      errors: json[:errors].present? ? json[:errors] : [],
      metadata: json[:meta]
    }
  end
end

GROOVE_API.setup url: "https://api.groovehq.com/v1/" do |c|
  # Request
  c.use GrooveTokenAuth
  c.use Faraday::Request::UrlEncoded

  # c.response :detailed_logger, Logger.new(STDOUT)

  # Response
  # c.use Her::Middleware::DefaultParseJSON
  c.use GrooveParser

  # Adapter
  c.use Faraday::Adapter::NetHttp
end