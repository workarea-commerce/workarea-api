Workarea.config.api_product_image_jobs_blacklist ||= %i[convert encode rotate optim avatar thumb]
Workarea.config.authentication_token_expiration ||= 1.week

# Ok, this one's a doozy.
#
# To deliver segmentation in the storefront API, we need a way to change a
# {Visit}'s definition of things like sessions, cookies, auth, etc.
#
# Since segments are determined first (before any other middleware), we need a
# way to know whether this is an API request to for logic in {Visit}.
#
# Since this is before any other middleware (including Rails' routing), we don't
# have a way to check the controller class or anything else application-related
# for whether it's an API request or an ordinary request.
#
# The best thing I could come up with is this regex. This lambda provides a hook
# for builds in case it doesn't work. They can provide their own logic here.
#
Workarea.config.is_api_visit = lambda do |request|
  request.original_url =~ /:\/\/api\.|\/api\/./
end
