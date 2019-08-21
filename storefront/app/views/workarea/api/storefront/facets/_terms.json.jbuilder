json.type facet.type
json.name facet.name
json.display_name facet.display_name

json.results facet.results do |name, count|
  json.name name
  json.count count
end
