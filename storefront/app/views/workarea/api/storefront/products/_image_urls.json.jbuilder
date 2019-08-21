processors = Dragonfly.app(:workarea).processors.items
json.urls processors.except(*Workarea.config.api_product_image_jobs_blacklist) do |name, _value|
  json.type name
  json.url product_image_url(image, name)
end
