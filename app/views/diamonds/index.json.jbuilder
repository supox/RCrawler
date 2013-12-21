json.array!(@diamonds) do |diamond|
  json.extract! diamond, :id, :shape, :size, :color, :clarity, :cut, :polish, :sym, :flour, :number_of_results, :rap_percentage
  json.url diamond_url(diamond, format: :json)
end
