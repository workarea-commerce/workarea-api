json.payment do
  json.complete step.complete?
  json.problems step.payment.errors.full_messages

  json.tenders summary.payment.tenders do |tender|
    json.partial! "workarea/api/storefront/orders/tenders/#{tender.slug}", tender: tender
    json.problems tender.errors.full_messages
  end
end
