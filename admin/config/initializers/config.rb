Workarea.config.permissions_fields << 'api_access'
Workarea.config.max_api_bulk_data_size ||= 1_000
Workarea.config.api_admin_ignore_definitions ||= [
  /^Workarea::Metrics/,
  /^Workarea::Insights/,
  /^Workarea::Reports/,
  /^Workarea::BulkAction/,
  /^Workarea::Help/,
  /Workarea::User::AdminBookmark/,
  /Workarea::User::RecentPassword/,
  /Workarea::User::PasswordReset/,
  /Workarea::User::AuthenticationToken/,
  /Workarea::Api::Admin::BulkUpsert/,
  /Workarea::User::AdminVisit/
]
