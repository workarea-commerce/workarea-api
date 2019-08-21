json.shipping do
  json.complete summary.shipping_service.present? && step.complete?
  json.problems summary.shipping.errors.full_messages

  json.shipping_service summary.shipping_service
  json.shipping_total cart.shipping_total

  json.partial! 'workarea/api/storefront/checkouts/shipping_options', cart: cart
end
