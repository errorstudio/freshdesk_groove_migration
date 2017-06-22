FRESHDESK_API = Her::API.new


FRESHDESK_API.setup url: "https://errorstudio.freshdesk.com/api/v2" do |c|
  # Request
  c.use Faraday::Request::UrlEncoded
  c.use Faraday::Request::BasicAuthentication, $credentials[:freshdesk],'x'

  # c.response :detailed_logger, Logger.new(STDOUT)

  # Response
  c.use Her::Middleware::DefaultParseJSON

  # Adapter
  c.use Faraday::Adapter::NetHttp
end