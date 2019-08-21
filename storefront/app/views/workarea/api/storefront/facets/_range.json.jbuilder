json.type facet.type
json.name facet.name
json.display_name facet.display_name

json.results facet.results do |range, count|
  json.range range
  json.count count
end
