Raddocs.configure do |config|
  config.api_name = 'Workarea API Documentation'

  host_app_docs_dir = Rails.root.join('doc', 'api')
  plugin_docs_dir = Workarea::Api.root.join('doc', 'api')

  config.docs_dir = if File.directory?(host_app_docs_dir)
    host_app_docs_dir
  else
    plugin_docs_dir
  end
end
