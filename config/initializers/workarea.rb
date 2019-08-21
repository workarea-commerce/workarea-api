Workarea.configure do |config|
  config.suppress_api_response_headers = %w[X-Flash-Messages Set-Cookie]
end
