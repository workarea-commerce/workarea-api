json.user_id current_user.id
json.credit_cards @credit_cards do |credit_card|
  json.partial! 'workarea/api/storefront/saved_credit_cards/card', card: credit_card
end
