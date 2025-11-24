def sort_keys(h)
  keys = h.keys.sort
  Hash[keys.zip(h.values_at(*keys))]
end