json.addresses do
  json.complete step.complete?
  json.email summary.email
  json.problems summary.order.errors.full_messages

  json.shipping_address do
    if summary.shipping_address.present?
      json.partial! 'workarea/api/storefront/shared/address', address: summary.shipping_address
      json.problems summary.shipping_address.errors.full_messages
    end
  end

  json.billing_address do
    if summary.billing_address.present?
      json.partial! 'workarea/api/storefront/shared/address', address: summary.billing_address
      json.problems summary.billing_address.errors.full_messages
    end
  end
end
