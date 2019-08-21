module Workarea
  class RemoveAuthenticationTokensOnPasswordChanges
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        User => [:save],
        ignore_if: -> { new_record? || changes['password_digest'].blank? },
        with: -> { [id] }
      },
      unique: :until_executing
    )

    def perform(id)
      User.find(id).authentication_tokens.destroy_all
    end
  end
end
