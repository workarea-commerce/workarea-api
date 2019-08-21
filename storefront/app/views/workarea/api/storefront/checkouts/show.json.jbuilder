json.order do
  json.partial! 'workarea/api/storefront/orders/order', order: @order
end

json.checkout do
  json.url checkout_url(@cart.id)
  json.started_at @cart.checkout_started_at
  json.shippable @summary.shippable?
  json.complete @summary.complete?

  @summary.steps.each do |klass|
    json.partial! "workarea/api/storefront/checkouts/steps/#{checkout_step_name(klass)}",
      step: klass.new(@summary.model),
      summary: @summary,
      cart: @cart
  end
end
