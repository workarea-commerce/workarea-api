module Workarea
  class PerformApiBulkUpsert
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Api::Admin::BulkUpsert => :create },
      retry: false
    )

    def perform(id)
      Api::Admin::BulkUpsert.find(id).perform!
    end
  end
end
