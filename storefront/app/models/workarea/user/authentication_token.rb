module Workarea
  class User
    class AuthenticationToken
      include ApplicationDocument
      include UrlToken

      field :expires_at, type: Time, default: -> { AuthenticationToken.expires_at }

      belongs_to :user, class_name: 'Workarea::User', index: true

      def self.expires_at
        Time.now + Workarea.config.authentication_token_expiration
      end

      def self.authenticate(token, options = {})
        result = where(token: token).first
        return if result.try(:expired?)
        result
      end

      def self.refresh!(token, options = {})
        result = where(token: token).first
        return if result.try(:expired?)
        return unless result.update_attribute(:expires_at, expires_at)
        result
      end

      def expired?
        expires_at <= Time.now
      end
    end
  end
end
