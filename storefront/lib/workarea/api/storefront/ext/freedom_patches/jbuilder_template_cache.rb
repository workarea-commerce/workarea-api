class JbuilderTemplate < Jbuilder
  def _cache_fragment_for(key, options, &block)
    return super(key, options) unless workarea_admin_accessing_api_route?

    key = _cache_key(key, options)

    _write_fragment_cache(key, options, &block)
  end

  private

  def workarea_admin_accessing_api_route?
    @context.controller.is_a?(::Workarea::Api::Storefront::ApplicationController) &&
      @context.controller.authentication? &&
        @context.controller.current_user.admin?
  end
end
